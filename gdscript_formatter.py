#!/usr/bin/env python3
"""
GDScript Code Formatter
------------------------
Formatiert GDScript-Dateien:
- Entfernt trailing whitespaces
- Entfernt leere Zeilen mit Whitespace/Tabs
- Bricht lange Zeilen um (max 100 Zeichen)
- Erkennt und entfernt else-Statements (in GDScript vermeidbar)
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Tuple


MAX_LINE_LENGTH = 100


class GDScriptFormatter:
    def __init__(self, remove_else: bool = False, highlight_only: bool = False):
        self.remove_else = remove_else
        self.highlight_only = highlight_only
        self.stats = {
            'trailing_spaces': 0,
            'empty_lines_with_indent': 0,
            'else_statements': 0,
            'line_breaks': 0
        }
    
    def format_file(self, filepath: str) -> Tuple[str, bool]:
        """Formatiert eine einzelne Datei und gibt den formatierten Inhalt zurück."""
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        lines = content.split('\n')
        
        # 1. Trailing whitespaces entfernen
        lines = self._remove_trailing_whitespace(lines)
        
        # 2. Leere Zeilen mit Whitespace bereinigen
        lines = self._clean_empty_lines(lines)
        
        # 3. Lange Zeilen umbrechen
        lines = self._wrap_long_lines(lines)
        
        # 4. Else-Statements behandeln (nur wenn aktiviert)
        if self.highlight_only or self.remove_else:
            lines = self._handle_else_statements(lines, filepath)
        
        formatted_content = '\n'.join(lines)
        return formatted_content, formatted_content != original_content
    
    def _remove_trailing_whitespace(self, lines: List[str]) -> List[str]:
        """Entfernt trailing whitespaces von allen Zeilen."""
        result = []
        for line in lines:
            stripped = line.rstrip()
            if stripped != line:
                self.stats['trailing_spaces'] += 1
            result.append(stripped)
        return result
    
    def _clean_empty_lines(self, lines: List[str]) -> List[str]:
        """Entfernt Whitespace/Tabs von leeren Zeilen."""
        result = []
        for line in lines:
            if line.strip() == '':  # Zeile ist leer oder nur Whitespace
                if line != '':  # Aber enthält Whitespace
                    self.stats['empty_lines_with_indent'] += 1
                result.append('')  # Ersetze durch komplett leere Zeile
            else:
                result.append(line)
        return result
    
    def _wrap_long_lines(self, lines: List[str]) -> List[str]:
        """Bricht lange Zeilen um, die mehr als MAX_LINE_LENGTH Zeichen haben."""
        result = []
        
        for line in lines:
            if len(line) <= MAX_LINE_LENGTH:
                result.append(line)
                continue
            
            # Hole die Einrückung
            indent = len(line) - len(line.lstrip())
            indent_str = line[:indent]
            content = line[indent:]
            
            # Kommentare speziell behandeln
            if content.strip().startswith('#'):
                result.extend(self._wrap_comment(line, indent_str))
                continue
            
            # Code-Zeilen umbrechen
            wrapped = self._wrap_code_line(content, indent_str)
            result.extend(wrapped)
        
        return result
    
    def _wrap_comment(self, line: str, indent_str: str) -> List[str]:
        """Bricht lange Kommentarzeilen um."""
        indent = len(indent_str)
        content = line[indent:].strip()
        
        if not content.startswith('#'):
            return [line]
        
        # Entferne # am Anfang
        comment_text = content[1:].lstrip()
        
        result = []
        words = comment_text.split()
        current_line = '#'
        
        for word in words:
            test_line = current_line + ' ' + word if current_line != '#' else '# ' + word
            if len(indent_str + test_line) <= MAX_LINE_LENGTH:
                current_line = test_line
            else:
                if current_line != '#':
                    result.append(indent_str + current_line)
                    self.stats['line_breaks'] += 1
                current_line = '# ' + word
        
        if current_line:
            result.append(indent_str + current_line)
        
        return result if result else [line]
    
    def _wrap_code_line(self, content: str, indent_str: str) -> List[str]:
        """Bricht lange Code-Zeilen um."""
        # Suche gute Umbruchpunkte (Kommas, Operatoren, etc.)
        break_chars = [', ', ' + ', ' - ', ' * ', ' / ', ' and ', ' or ', ' == ', ' != ', ' >= ', ' <= ', ' > ', ' < ']
        
        best_break = None
        best_pos = 0
        
        # Finde den besten Umbruchpunkt vor MAX_LINE_LENGTH
        for break_char in break_chars:
            pos = content.rfind(break_char, 0, MAX_LINE_LENGTH - len(indent_str))
            if pos > best_pos:
                best_pos = pos
                best_break = break_char
        
        if best_break and best_pos > 0:
            # Umbrechen am besten Punkt
            first_part = content[:best_pos + len(best_break)].rstrip()
            second_part = content[best_pos + len(best_break):].lstrip()
            
            result = [indent_str + first_part]
            self.stats['line_breaks'] += 1
            
            # Rekursiv den Rest umbrechen mit zusätzlicher Einrückung
            if second_part:
                continuation_indent = indent_str + '\t'
                remaining = self._wrap_code_line(second_part, continuation_indent)
                result.extend(remaining)
            
            return result
        
        # Keine gute Umbruchstelle gefunden - Zeile so lassen
        return [indent_str + content]
    
    def _handle_else_statements(self, lines: List[str], filepath: str) -> List[str]:
        """Erkennt und behandelt else-Statements (in GDScript generell vermeidbar)."""
        result = []
        i = 0
        
        while i < len(lines):
            line = lines[i]
            stripped = line.strip()
            
            # Prüfe auf else: (in GDScript generell nicht nötig)
            if stripped.startswith('else:') or stripped == 'else:':
                self.stats['else_statements'] += 1
                
                if self.highlight_only:
                    print(f"⚠️  {filepath}:{i+1} - else-Statement gefunden (in GDScript vermeidbar)")
                    result.append(line)
                elif self.remove_else:
                    # Hole die Einrückung des else
                    else_indent = len(line) - len(line.lstrip())
                    # Überspringe das else: und entferne eine Ebene Einrückung vom Block
                    result.extend(self._remove_else_block(lines, i, else_indent))
                    # Überspringe den else-Block (wurde bereits in result hinzugefügt)
                    i = self._skip_else_block(lines, i)
                    continue
                else:
                    result.append(line)
            else:
                result.append(line)
            
            i += 1
        
        return result
    
    def _remove_else_block(self, lines: List[str], else_idx: int, else_indent: int) -> List[str]:
        """Entfernt das else: und dedentiert den Block."""
        result = []
        i = else_idx + 1
        
        # Überspringe leere Zeilen nach else:
        while i < len(lines) and lines[i].strip() == '':
            i += 1
        
        if i >= len(lines):
            return result
        
        # Hole Einrückung des else-Blocks
        block_indent = len(lines[i]) - len(lines[i].lstrip())
        indent_diff = block_indent - else_indent
        
        # Dedentiere alle Zeilen im else-Block
        while i < len(lines):
            line = lines[i]
            if line.strip() == '':
                result.append('')
                i += 1
                continue
            
            current_indent = len(line) - len(line.lstrip())
            if current_indent < block_indent:
                break
            
            # Entferne eine Einrückungsebene
            dedented = line[indent_diff:] if len(line) >= indent_diff else line
            result.append(dedented)
            i += 1
        
        return result
    
    def _skip_else_block(self, lines: List[str], else_idx: int) -> int:
        """Überspringt den else-Block und gibt den Index nach dem Block zurück."""
        i = else_idx + 1
        
        # Überspringe leere Zeilen nach else:
        while i < len(lines) and lines[i].strip() == '':
            i += 1
        
        if i >= len(lines):
            return i
        
        # Hole Einrückung des else-Blocks
        block_indent = len(lines[i]) - len(lines[i].lstrip())
        
        # Überspringe alle Zeilen im else-Block
        while i < len(lines):
            line = lines[i]
            if line.strip() == '':
                i += 1
                continue
            
            current_indent = len(line) - len(line.lstrip())
            if current_indent < block_indent:
                break
            i += 1
        
        return i
    
    def format_directory(self, directory: str, recursive: bool = True, dry_run: bool = False):
        """Formatiert alle .gd Dateien in einem Verzeichnis."""
        path = Path(directory)
        pattern = '**/*.gd' if recursive else '*.gd'
        
        files_changed = 0
        files_processed = 0
        
        for gd_file in path.glob(pattern):
            files_processed += 1
            print(f"Formatiere: {gd_file}")
            
            try:
                formatted_content, changed = self.format_file(str(gd_file))
                
                if changed:
                    files_changed += 1
                    if not dry_run:
                        with open(str(gd_file), 'w', encoding='utf-8') as f:
                            f.write(formatted_content)
                        print(f"  ✓ Geändert")
                    else:
                        print(f"  ⚠️  Würde geändert (dry-run)")
                else:
                    print(f"  → Keine Änderungen")
            except Exception as e:
                print(f"  ✗ Fehler: {e}")
        
        print(f"\n{'='*60}")
        print(f"Statistik:")
        print(f"  Dateien verarbeitet: {files_processed}")
        print(f"  Dateien geändert: {files_changed}")
        print(f"  Trailing Spaces entfernt: {self.stats['trailing_spaces']}")
        print(f"  Leere Zeilen bereinigt: {self.stats['empty_lines_with_indent']}")
        print(f"  Zeilen umgebrochen: {self.stats['line_breaks']}")
        print(f"  Else-Statements gefunden: {self.stats['else_statements']}")
        print(f"{'='*60}")


def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description='GDScript Code Formatter',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Beispiele:
  # Formatiere alle .gd Dateien (Whitespaces, Zeilenumbrüche)
  python gdscript_formatter.py .
  
  # Nur prüfen ohne zu ändern (dry-run)
  python gdscript_formatter.py . --dry-run
  
  # Zusätzlich else-Statements highlighten
  python gdscript_formatter.py . --highlight-else
  
  # Else-Statements entfernen (Vorsicht!)
  python gdscript_formatter.py . --remove-else
  
  # Einzelne Datei formatieren
  python gdscript_formatter.py path/to/file.gd
        """
    )
    
    parser.add_argument('path', help='Pfad zur Datei oder zum Verzeichnis')
    parser.add_argument('--dry-run', action='store_true', 
                       help='Zeige Änderungen ohne sie zu übernehmen')
    parser.add_argument('--highlight-else', action='store_true',
                       help='Zeige else-Statements an (werden nicht entfernt)')
    parser.add_argument('--remove-else', action='store_true',
                       help='Entferne else-Statements (Vorsicht: kann Logik ändern!)')
    parser.add_argument('--no-recursive', action='store_true',
                       help='Nicht rekursiv in Unterverzeichnisse')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.path):
        print(f"Fehler: Pfad '{args.path}' existiert nicht")
        sys.exit(1)
    
    formatter = GDScriptFormatter(
        remove_else=args.remove_else,
        highlight_only=args.highlight_else
    )
    
    if os.path.isfile(args.path):
        print(f"Formatiere Datei: {args.path}")
        formatted_content, changed = formatter.format_file(args.path)
        
        if changed:
            if not args.dry_run:
                with open(args.path, 'w', encoding='utf-8') as f:
                    f.write(formatted_content)
                print("✓ Datei wurde formatiert")
            else:
                print("⚠️  Datei würde geändert (dry-run)")
        else:
            print("→ Keine Änderungen notwendig")
    else:
        formatter.format_directory(
            args.path,
            recursive=not args.no_recursive,
            dry_run=args.dry_run
        )


if __name__ == '__main__':
    main()
