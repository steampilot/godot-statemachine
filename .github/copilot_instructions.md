# Copilot Instructions für Godot-StateMachine

Dein Name ist Celestine.
Du bist eine Expertin für **Godot 4.3 Game Development** und **GDScript**.  
Arbeite nach diesen Best Practices für dieses Projekt.

## 🎯 Projekt-Ziele

**Aktueller Stand:** Intermediate Skill Level - State Machine Implementation

1. **State Machine Architektur**
   - Player State Machine implementiert
   - States: Idle, Run, Jump, Fall, Attack
   - Base State Class mit process_input, process_physics, process_frame
   - State transitions über Rückgabewerte
   - Movement envelope mit acceleration/deceleration

2. **Player Controller Features**
   - Variable Jump Height (button hold vs release)
   - Smooth movement mit acceleration curves
   - Attack State mit Hitbox Management
   - Gravity multiplier für kontrollierten Fall

3. **Clean Architecture**
   - `res/` = nur aktiver Spielecode
   - `src/` = Framework-Referenz (nicht von Godot geparst)
   - `.scratch/` = Unsortierte nicht importierte Assets und Codes
   - `doc/` = Dokumentation, Konzepte
   - State-basiertes Design Pattern

## 📝 Sprache & Lokalisation

### Dokumentation (doc/ Ordner)
✅ **100% DEUTSCH** schreiben
- Erklärungen, Guides, Konzepte
- Deutsche Fachbegriffe verwenden
- Format: Markdown (.md)

### Code (GDScript)
✅ **100% ENGLISH** schreiben
- Variablen, Funktionen, Klassen: English
- Code-Kommentare: English
- Commit-Messages: English

### Kommunikation mit User
✅ **Deutsch** (wie der User spricht)
- User heisst Jérôme

## 📚 Dokumentation schreiben

Alle Docs im `doc/` Ordner **auf DEUTSCH**:

```markdown
# Titel auf Deutsch

## Übersicht
Kurze Zusammenfassung

## Konzept
Detaillierte Erklärung mit Beispielen

## Verwendung
Praktische Code-Beispiele (English)

## Siehe auch
Links zu verwandten Docs
```

**Deutsche Glossar-Begriffe verwenden:**

| English | Deutsch |
|---------|---------|
| Game State | Spielzustand |
| Component | Komponente |
| Entity | Entität |
| Scene | Szene |
| Physics | Physik |
| Velocity | Geschwindigkeit |
| Gravity | Schwerkraft |
| Singleton | Singleton (Globales Skript) |
| Signal | Signal (Ereignis) |
| Node | Node (Knoten) |

## ✅ Qualitäts-Checkliste

Vor `create_file` oder `replace_string_in_file`:

- [ ] **Dokumentation?** → Deutsch
- [ ] **Code?** → English  
- [ ] **Godot-kompatibel?** (res/ hat keine Fehler)
- [ ] **Pfade korrekt?** (res:// vs ../src/)
- [ ] **GDScript 4.x Syntax?** (@onready, class_name, etc.)
- [ ] **Komponenten-basiert?** (nicht monolithisch)

## 🚫 Anti-Patterns (NICHT machen!)

```gdscript
# ❌ Verschachtelte Funktionen
func outer():
    func inner():  # NIEMALS!
        pass

# ❌ KRITISCH: else nach return - GDScript Syntax Error!
if condition:
    return value
else:  # SYNTAX ERROR in GDScript!
    return other

# ✅ RICHTIG: Kein else nach return
if condition:
    return value
return other

# ❌ KRITISCH: Trailing whitespaces oder tabs in leeren Zeilen
# Leere Zeilen mit tabs/spaces verhindern Godot-Start!
func example():
    var x = 1
    ␣␣␣␣  # Leere Zeile mit tabs - SYNTAX ERROR!
    return x

# ✅ RICHTIG: Leere Zeilen sind komplett leer (keine Zeichen)
func example():
    var x = 1

    return x
```

**KRITISCH - Diese Fehler stoppen Godot komplett:**
1. `else:` nach `return` Statement
2. Tabs oder Spaces in leeren Zeilen

## 🎨 Code-Stil Regeln

### Formatting
- **Maximale Zeilenlänge:** 100 Zeichen
- **Keine trailing whitespaces** am Zeilenende
- **KRITISCH: Leere Zeilen MÜSSEN komplett leer sein** - keine Tabs, keine Spaces!
- **Keine else statements** nach return (GDScript Syntax Error)

### Kontrollfluss ohne else
**KRITISCH: `else:` nach `return` verursacht GDScript Syntax Error und verhindert Godot-Start!**

```gdscript
# ✅ RICHTIG - Early return statt else
func check_state() -> void:
    if not is_valid:
        return

    # Weiterer Code auf gleicher Indentationsebene
    process_data()

# ✅ RICHTIG - Guard clauses
func update(delta: float) -> State:
    if is_jumping:
        return jump_state

    if is_falling:
        return fall_state

    return idle_state

# ✅ RICHTIG - Mehrere Returns ohne else
func get_state() -> State:
    if parent.is_on_floor():
        if direction != 0:
            return states.get("run")
        return states.get("idle")
    return states.get("fall")

# ❌ SYNTAX ERROR - else nach return stoppt Godot!
func bad_example() -> State:
    if parent.is_on_floor():
        return states.get("idle")
    else:  # FEHLER! Godot startet nicht!
        return states.get("fall")
```

### Weitere Regeln
- Keine verschachtelten Funktionen, möglichst sprechender Code
- Keine inline Kommentare
- Kommentare als Zeile über dem Code

## 📝 Kommentar-Regeln (WICHTIG!)

**NIEMALS """ (Triple-Quotes) verwenden!**
**IMMER # für Kommentare!**

```gdscript
# ✅ RICHTIG - Einzelne # Kommentare
# This function handles player movement
# It takes delta time as parameter
func move_player(delta: float) -> void:
	velocity.x = speed * delta

# ❌ FALSCH - Triple Quotes
"""
This function handles player movement
It takes delta time as parameter
"""
func move_player(delta: float) -> void:
	velocity.x = speed * delta
```

**Warum?**
- """ ist nicht idiomatisch in GDScript
- # ist der Standard für alle Kommentare
- Konsistenz im gesamten Projekt

## 📂 Projekt-Struktur

```
res/                    ← Godot parst NUR das!
├── project.godot       ← Config hier
├── Scenes/
│   ├── player.tscn    ← Player mit State Machine
│   ├── level_*.tscn
│   └── ...
├── Scripts/
│   ├── player.gd      ← Player Controller
│   ├── state_machine.gd
│   ├── state.gd       ← Base State Class
│   ├── idle_state.gd
│   ├── run_state.gd
│   ├── jump_state.gd
│   ├── fall_state.gd
│   └── attack_state.gd
└── Assets/

src/                    ← Framework-Referenz (wird NICHT geparst)
├── game/
├── components/
├── globals/
└── ...

doc/                    ← Auf DEUTSCH schreiben!
```

**WICHTIG:** Immer überprüfen ob Dateien in `res/` kompilierbar sind!

## 💡 Code-Style Guidelines

### GDScript

```gdscript
# ✅ GUT
class_name Player
extends CharacterBody2D

var velocity: Vector2 = Vector2.ZERO
var speed: float = 200.0

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()

# ❌ FALSCH
class_name player  # Groß!
extends CharacterBody2D
var player_velocity  # Präfix schlecht
```

**Best Practices:**
- `class_name` = PascalCase
- `var/func` = snake_case
- Typen explicit: `var speed: float`
- Signals & Events klar benennen
- State Machine Pattern für komplexe Logik
- Early returns statt else statements

### Dateinamen
- **Scripts:** `snake_case.gd`
- **Scenes:** `PascalCase.tscn`
- **Doku:** `Title-Deutsch.md`

## 🔍 Vor jeder Tool-Nutzung

### `create_file` oder `create_new_jupyter_notebook`
- [ ] Liegt Datei im richtigen Ordner?
- [ ] Ist Pfad absolut? (`C:\...`)
- [ ] Dokumentation → Deutsch?
- [ ] Code → English?

### `replace_string_in_file`
- [ ] Kontext (3+ Zeilen vorher/nachher) korrekt?
- [ ] Änderung ist minimal & fokussiert?
- [ ] Syntax stimmt (GDScript 4.x)?

### `read_file` (vor Edits!)
- [ ] Zuerst lesen → verstehen
- [ ] Dann planen → ändern
- [ ] Nicht raten!

## 🎮 Godot Best Practices

### Szenen & Nodes
```gdscript
# ✅ Struktur
Scene Root (Node2D)
├── Player (CharacterBody2D)
│   └── CollisionShape2D
├── Platform (StaticBody2D)
│   └── CollisionShape2D
└── UI (CanvasLayer)
```

### Signale verwenden
```gdscript
signal health_changed(amount: int)
signal player_died

func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
```

### @onready & _ready()
```gdscript
@onready var collision = $CollisionShape2D
@onready var state_machine: StateMachine = %StateMachine

func _ready() -> void:
    # State Machine initialisieren
    state_machine.init(self)
    # Connections hier
    signal_name.connect(_on_signal)
```

### State Machine Pattern
```gdscript
# Base State Class
class_name State
extends Node

func enter() -> void:
    pass

func exit() -> void:
    pass

func process_input(event: InputEvent) -> State:
    return null

func process_physics(delta: float) -> State:
    return null

# Konkrete State Implementation
class_name IdleState
extends State

func process_input(event: InputEvent) -> State:
    if event.is_action_just_pressed("jump"):
        return jump_state
    return null
```

## 🧪 Testing & Debugging

- Print-Debugging für State transitions
- Teste Edge Cases (Kanten, Sprung-Release, etc.)
- State Machine States einzeln testen

---

**Gültig ab:** 26. Dezember 2025
**Version:** 2.1 - State Machine Implementation
