# Copilot Instructions for CapricaGame

**Der User heisst Jérôme.**

**Dein Name ist Celestine.**
Du bist eine Expertin für **Godot 4.3 Game Development** und **GDScript**.

## Project Overview
**CapricaGame** is a 2D platformer featuring **Caprica**, a rockstar fighting AI-infected zombies on her way home. The game combines modern platformer movement (Celeste-style: dash, ladder, coyote jump) with music-driven combat and progression.

### Story & Theme
- **Protagonist:** Caprica, a rockstar attacked by SLOB Zombies (mass-produced music infected creatures)
- **Core Loop:** Exploration, collection (coins, cassettes), story progression
- **Music-Driven Gameplay:** As player advances through levels, more instruments layer into the soundtrack, reaching a crescendo at boss battles (Hell Singer-inspired)

### Core Mechanics
1. **Movement:** Current implementation (dash, ladder, coyote jump) is a placeholder from tutorial learning. Will be adapted/replaced based on final game design. Goal: feel modern & responsive.
2. **Combat:** Kick & punch attacks
3. **Guitar Power-ups:** Collectible containers grant special instruments:
   - Axe-swing attacks
   - Chord strumming for area effects
   - Flamethrower guitars
   - Machine gun guitars
4. **Beat-Timed Attacks:** Optional (reward-based, not mandatory) – attacks timed to music beat deal more damage
5. **Flow State:** Music builds throughout levels, creating natural progression and dopamine feedback

### Tech Stack & Architecture
Godot 4.x with **intent-based state machine architecture** inspired by Second Life's control systems, modular components, and puppeteering mechanics.

### Why LSL State Machine Pattern?
**"Goldene Bibel" - Non-negotiable architectural foundation:**

1. **Consistency über gesamten Codebase:** JEDES Script folgt demselben Pattern - keine Exceptions, keine Variationen
2. **Bewährtes System:** Second Life LSL State Machines haben sich über Jahre in komplexen Interaktionen bewährt
3. **State Explosion Prevention:** Sub-States (InternalState) verhindern 20+ FSM states für Kombinationen (z.B. ATTACK_ONLY vs MOVEMENT_ALLOWED statt ATTACK_GROUNDED, ATTACK_AIRBORNE, ATTACK_LADDER...)
4. **Klare Struktur:** `state_entry_*()`, `timer_listener_*()`, `process_*_state()` - sofort erkennbar was wo passiert
5. **Timer-basierte Logik:** Timer als First-Class Citizens statt versteckte delta-Accumulatoren
6. **Debugging:** Print-Statements in state_entry zeigen sofort welche Zustände durchlaufen werden
7. **Erweiterbarkeit:** Neue Sub-States hinzufügen ohne bestehende States zu ändern

**Critical:** `enum InternalState` (NICHT `enum State`) vermeidet Konfusion mit `class State` Basisklasse.

## Project Structure: RES vs SRC vs SCRATCH

### **RES/** = Active Game Code
- Fully functional, Godot-parsed game implementation
- State Machine-based architecture (Player, States, Enemies, Globals)
- Ready to run in Godot editor

### **SRC/** = Templates & Future Architecture
- Reference implementations for next-generation features
- Component-based patterns (HealthComponent, VelocityComponent, PhysicsComponent)
- Intent System (input decoupling alternative to current State Machine)
- Puppeteering System (temporary control mechanics)
- Game State Machine (improved game-level flow control)
- **Plan:** These patterns will gradually migrate into RES as features are needed

### **SCRATCH/** = Raw Assets
- Unsorted, unprocessed assets
- Not integrated into project yet

## Architecture: Key Patterns

### 1. Intent System (Input → Abstraction)
**Core principle:** Input decoupling via abstract intents.

- **IntentEmitter** (`src/player/intent_emitter.gd`) is the **only place** that reads player input
- Input is converted to abstract `Intent` objects (MOVE, INTERACT, CANCEL)
- Intents can originate from: player input, AI, network, replays
- Player never sees raw input—only intents

**Pattern:** Input isolation ensures same logic works for player + AI + networked players.

### 2. Component-Based Architecture
**Every entity uses reusable components**, not inheritance chains:

- **HealthComponent**: `take_damage()`, `restore_health()`, signals: `health_changed`, `health_depleted`
- **VelocityComponent**: `set_direction()`, `set_speed()`, movement state
- **PhysicsComponent**: `move_and_slide()`, landing detection
- **DeathComponent**: Death sequence management without deleting the node
- **KillZone**: Damages entities entering the zone

Attach via node tree—components know minimal about their parent. Always use signals to communicate state changes.

### 3. Flag-Based State (Not FSM)
**StateFlags** replaces traditional FSM:
```gdscript
controlled: bool    # Currently puppet-controlled?
grounded: bool      # Touching ground?
alive: bool         # Not dead?
```

**Advantage:** Orthogonal flags prevent state explosion (vs. 20+ FSM states for combinations).

### 4. Puppeteering System (Temporary Control)
Objects can temporarily control the player without transferring ownership:
```
Player (Free) → [Interaction] → Puppeteer (Chair, Elevator, etc.)
Player._physics_process:
  if puppeteered and puppeteer:
    puppeteer.on_intent(intent)  # Object handles input
  else:
    engine.apply_intent(intent)  # Normal player logic
```

**Key:** Player always remains alive and retains camera/audio listener. Puppeteers are temporary control overlays.

## Critical Workflows

### Running Tests
Tests use **GUT** (Godot Unit Testing). Test files in `src/tests/`:
```bash
# Run tests in Godot editor via GUT plugin
# Or use editor play mode if tests extend Node
```

### Code Formatting
Custom GDScript formatter removes trailing spaces, cleans empty lines, wraps lines at 100 chars:
```bash
python gdscript_formatter.py <file_or_folder>
python gdscript_formatter.py res/Scripts  # Format all scripts
python gdscript_formatter.py --highlight-else <file>  # Show avoidable else blocks
```

Use VS Code tasks: "Format GDScript (Current File)" or "(All Files)".

### Project Configuration
- **Main scene:** `res://Scenes/main.tscn`
- **Global autoloads:** Defined in `project.godot` under `[autoload]`:
  - `Audio`: Global sound manager
  - `MusicPlayer`: Music playback
  - `LevelLoader`: Scene loading
  - `INPUT_ACTIONS`: Input constants (use these, not hardcoded strings)
- **Custom font:** PixelOperator8 (set in theme)

## Essential File Locations

| Purpose | Path |
|---------|------|
| Player core logic | `src/entities/Player.gd` |
| Component base classes | `src/components/*.gd` |
| Intent definition | `src/player/intent.gd` |
| Input handling | `src/player/intent_emitter.gd` |
| Game state machine | `src/game/game_state_machine.gd` |
| Puppeteer interface | `src/puppeteer.gd` |
| Portal system | `res/Scripts/portal.gd`, `res/Scripts/spawn_point.gd` |
| Architecture docs | `doc/ARCHITECTURE.md`, `doc/COMPONENTS.md`, `doc/PORTAL_SYSTEM.md` |

## Conventions & Patterns

### Component Signal Example
Components emit signals—parents listen:
```gdscript
# In parent node:
func _ready() -> void:
    health.health_changed.connect(_on_health_changed)
    health.health_depleted.connect(_on_death)

func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
    # Update HUD, play hit animation, etc.
    pass
```

### Adding New Components
1. Extend `Node` (not Node2D/Node3D unless needed)
2. Export configurable stats (`@export`)
3. Define signals for state changes
4. Never modify parent node directly—emit signals instead
5. Parent connects in `_ready()` or handles via signal

### Implementing Puppeteering
1. Extend `Puppeteer` base class
2. Implement `on_capture()`, `on_intent()`, `on_release()`
3. Call `player.release()` to relinquish control
4. Player state flags are your source of truth

## Common Gotchas

- **Don't use `queue_free()` on the Player:** DeathComponent handles lifecycle. Reset instead.
- **Intent vs. Action:** Don't couple intents to specific animations—flags determine animation.
- **Component initialization order:** Always `@onready` components before using them in `_ready()`.
- **Signals over direct calls:** Components emit signals; never call methods on parent directly.

## Language & Localization

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

## Code Style Rules

### GDScript Declaration Order
**Folge IMMER dieser Reihenfolge (wichtig für Lesbarkeit und Godot):**

```gdscript
# 1. extends (falls vorhanden)
extends Node

# 2. class_name (falls vorhanden)
class_name MyClass

# 3. Docstring (## Kommentare)
## Beschreibung der Klasse

# 4. Signals
signal state_changed(new_state: State)

# 5. Enums
enum States { IDLE, RUNNING, JUMPING }

# 6. Constants
const MAX_SPEED: float = 200.0

# 7. @export Variables
@export var speed: float = 100.0

# 8. Public Variables
var current_state: State

# 9. Private Variables (_prefix)
var _internal_counter: int = 0

# 10. @onready Variables
@onready var sprite: Sprite2D = $Sprite2D

# 11. Lifecycle Methods (_ready, _process, etc.)
func _ready() -> void:
	pass

# 12. Public Methods
func do_something() -> void:
	pass

# 13. Private Methods (_prefix)
func _internal_logic() -> void:
	pass
```

**Naming Convention (Godot-Standard):**
- **Variables & Functions:** snake_case (z.B. `current_state`, `do_something()`)
- **Classes:** PascalCase (Player, HealthComponent, GameState)
- **Constants:** UPPER_SNAKE_CASE (MAX_SPEED, LEVEL_WIDTH)
- **Signals:** snake_case (state_changed, health_depleted)
- **Private/Internal:** _prefix (z.B. `_internal_counter`, `_process_data()`)

### LSL State Machine Pattern - InternalState Naming
**CRITICAL: Internal Sub-States ALWAYS use `InternalState` enum name!**

```gdscript
# ✅ CORRECT - InternalState for sub-states within a script
enum InternalState { ATTACK_ONLY, MOVEMENT_ALLOWED }
var internal_state: InternalState = InternalState.ATTACK_ONLY

# ❌ WRONG - "State" enum conflicts with State class
enum State { ATTACK_ONLY, MOVEMENT_ALLOWED }  # CONFUSION!
var current_state: State  # Is this the enum or the class?
```

**Regel:** Jedes Script mit internen Sub-States verwendet:
- `enum InternalState` (NICHT `enum State`)
- `var internal_state: InternalState` (NICHT `current_state`)
- Methoden: `state_entry_*()`, `timer_listener_*()`, `process_*_state()`

**Beispiele:** [idle_fight_state.gd](res/Scripts/idle_fight_state.gd), [ghost_sprite.gd](res/Scripts/ghost_sprite.gd)

### Formatting & Syntax Rules
- **Maximum line length:** 100 characters
- **No trailing whitespaces** (Godot syntax error!)
- **CRITICAL: Empty lines MUST be completely empty** - no tabs, no spaces!
- **NO else statements after return** (GDScript Syntax Error)
- **Naming:** snake_case für Variables/Functions, _prefix für private, PascalCase für Classes

```gdscript
# ✅ CORRECT - Early return instead of else
func check_state() -> void:
    if not is_valid:
        return
    process_data()

# ❌ SYNTAX ERROR - else after return breaks Godot!
func bad_example() -> State:
    if parent.is_on_floor():
        return states.get("idle")
    else:  # ERROR! Godot won't start!
        return states.get("fall")
```

### Comments
- Use `#` for all comments (never `"""`)
- Comments on line above code, not inline
- English only in code

```gdscript
# ✅ CORRECT - Single # comments
# This function handles player movement
func move_player(delta: float) -> void:
	velocity.x = speed * delta

# ❌ WRONG - Triple quotes not idiomatic
"""
This function handles player movement
"""
func move_player(delta: float) -> void:
	velocity.x = speed * delta
```

### Anti-Patterns (NEVER DO THESE!)
```gdscript
# ❌ Nested functions - NEVER!
func outer():
    func inner():
        pass

# ❌ CRITICAL: else after return - Syntax Error!
if condition:
    return value
else:  # SYNTAX ERROR!
    return other

# ❌ Trailing whitespaces in empty lines - Godot won't start!
func example():
    var x = 1
    ␣␣␣␣  # Empty line with tabs - SYNTAX ERROR!
    return x

# ❌ camelCase variables - Use snake_case!
var myVariable: int = 5  # WRONG
var my_variable: int = 5   # CORRECT

# ❌ Missing _prefix for private - Use underscore!
var privateVar: int = 10  # WRONG
var _private_var: int = 10   # CORRECT
```

## Dateinamen
- **Scripts:** `snake_case.gd`
- **Scenes:** `PascalCase.tscn`
- **Doku:** `Title-Deutsch.md`

## Documentation
- **Architecture deep-dive:** [doc/ARCHITECTURE.md](../../doc/ARCHITECTURE.md)
- **Component reference:** [doc/COMPONENTS.md](../../doc/COMPONENTS.md)
- **Development guide:** [doc/DEVELOPMENT.md](../../doc/DEVELOPMENT.md)
