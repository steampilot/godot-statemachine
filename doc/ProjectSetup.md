# Project Setup Guide

## Projektstruktur

### Verzeichnis-Übersicht

```
Godot-StateMachine/
│
├── res/                          (← Godot's res:// directory ROOT!)
│   ├── project.godot             (← Projekt-Konfiguration)
│   ├── icon.svg                  (← Projekt-Icon)
│   │
│   ├── Scenes/                   (← Spielszenen & Levels)
│   │   ├── main.tscn
│   │   ├── level_1.tscn
│   │   └── main_menu.tscn
│   │
│   ├── Scripts/                  (← Game-spezifische Scripts)
│   │   ├── main.gd               (erbt von MAIN Global)
│   │   └── main_menu.gd          (erbt von MainMenu)
│   │
│   └── Assets/                   (← Grafiken, Audio, Daten)
│       ├── Graphics/
│       ├── Audio/
│       └── Data/
│
├── src/                          (← Framework-Code (parallel zu res/))
│   ├── game/                     (State Machine, Controllers)
│   ├── components/               (HealthComponent, PhysicsComponent, etc.)
│   ├── entities/                 (Base-Klassen: Player, Platformer, Enemy)
│   ├── globals/                  (AUDIO, HEALTH, MAIN Singletons)
│   ├── player/                   (Motor, Engine, Intent)
│   ├── objects/                  (Ball, Chair, etc.)
│   └── tests/                    (Integrationstests)
│
└── doc/                          (← Dokumentation)
    ├── ProjectSetup.md           (← Du bist hier!)
    ├── Development.md
    ├── ARCHITECTURE.md
    ├── COMPONENTS.md
    └── ...
```

## Wichtige Konzepte

### 1. `res://` Directory
- **Location:** `C:\...\Godot-StateMachine\res\`
- **Was ist hier:** ALLES was Godot beim Starten parst und compiliert
- **Nur produktiver Spielcode!**
- **Keine Framework-Fehler in diesem Ordner!**
- **project.godot muss hier liegen!**

### 2. `src/` Directory (Parallel neben res/)
- **Location:** `C:\...\Godot-StateMachine\src\`
- **Was ist hier:** Vorgefertigte Base-Klassen und Konzepte
- **Godot parst das NICHT** - Keine Compile-Fehler!
- **Später:** Base-Klassen bei Bedarf nach `res/Scripts/` kopieren
- **ACHTUNG:** Nicht in `res/` sondern PARALLEL!

### 3. Naming-Konvention

**Global Base-Klassen** (in `framework/src/`):
```gdscript
class_name MAIN              # ← UPPERCASE
extends Node
```

**Lokale Spezialisierung** (in `res/Scripts/`):
```gdscript
# res/Scripts/main.gd
extends MAIN                 # ← Erbt automatisch (class_name macht es global verfügbar!)
```

## Autoload (Global Singletons)

**WICHTIG für JETZT:** Autoloads sollten **NICHT** verwendet werden, solange die Base-Klassen in `src/` liegen (außerhalb von `res://`).

Wenn du Singletons später brauchst, kopiere sie nach `res/Scripts/` und registriere sie dann:

```ini
[autoload]
Main="res://Scripts/MAIN.gd"        ← Muss in res/ liegen!
HEALTH="res://Scripts/HEALTH.gd"
```

## Entwicklungs-Workflow

### Start einer Session

1. **Godot öffnen** → `res/project.godot` (liegt in res/ Ordner!)
2. **Spielszenen in `res/Scenes/` erstellen**
3. **Lokale Scripts in `res/Scripts/` schreiben**
4. **Framework-Code konsultieren** (in `../src/`) - wird von Godot NICHT geparst!

### Base-Klasse integrieren

Wenn du eine Base-Klasse aus `../src/` brauchen:

1. **Option A:** Kopiere sie nach `res/Scripts/`
2. **Option B:** Schreibe eine lokale Version, die das gleiche macht
3. **Option C:** Später: Verschiebe sie nach `res/Scripts/` wenn Framework reif ist

**Grund:** Godot darf `src/` nicht parsen (Compile-Fehler würden dich blockieren!)

## GDScript Tools

### gdtoolkit Installation

Siehe [Development.md](Development.md) für vollständige Setup-Anleitung.

**Quick Start:**
```bash
pip install gdtoolkit
gdformat res/ --recursive
```

## Häufige Probleme & Lösungen

### "Cannot compile - GameStateMachine error"

**Problem:** Framework-Code in `../src/` hat Fehler
**Lösung:** Godot parst `src/` nicht - Fehler wird ignoriert ✓

### "Script 'MAIN' not found"

**Problem:** `class_name MAIN` wurde nicht registriert oder liegt in `src/`
**Lösung:** 
- Kopiere `MAIN.gd` nach `res/Scripts/`
- Registriere es als Autoload in `project.godot`

### "res://src/globals/MAIN.gd - path not found"

**Problem:** `project.godot` versucht noch auf `res://src/` zuzugreifen
**Lösung:**
- Lösche Autoload-Einträge zu `res://src/*`
- Kopiere nur die Base-Klassen, die du brauchst nach `res/Scripts/`
- Registriere sie dort neu

## Next Steps

1. **Minimales Game:** Player auf Platform in `res/Scenes/main.tscn`
2. **Input handling:** Bewegung im `res/Scripts/main.gd`
3. **Schrittweise:** Components & Features hinzufügen
4. **Framework-Integration:** State Machine, Controller, Singletons - wenn die Basics laufen

## Resources

- [Godot Official Docs](https://docs.godotengine.org/)
- [GDScript Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Project Structure Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
