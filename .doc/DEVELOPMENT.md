# Development Guide für Copilot

## 🎯 Projekt-Überblick

**Technologie:** Godot 4.x + GDScript
**Pattern:** Intent-basiertes State Machine System (Second Life inspiriert)
**Ziel:** State Machine für 2D Platformer & Point-and-Click Adventures

## 📁 Projektstruktur

```
src/
├── player/
│   ├── player.gd              # Orchestrator (Input → Intent routing)
│   ├── engine.gd              # Physik-Executive (Intent → Movement)
│   ├── motor.gd               # Motion-Executive (StateFlags → Animation)
│   ├── state_flags.gd         # Truth Layer (controlled, grounded, alive)
│   ├── intent.gd              # Abstract Intent Definition
│   ├── intent_emitter.gd      # Input Handler (nur hier!)
│   └── player.tscn            # Player Scene Struktur
├── puppeteer.gd               # Base Class für controllable Objects
├── objects/                   # (TODO) Chair, Cola, etc.
└── scenes/                    # Main Levels
    └── main.tscn
```

## 🔑 Kernkonzepte (DU MUSST DIESE VERSTEHEN!)

### 1. **Intent-System** (Input-unabhängig)
- `IntentEmitter.gd` liest **nur hier** Input
- Input wird zu **abstrakte Intents** konvertiert (MOVE, INTERACT, CANCEL)
- Intents können auch von AI/Netzwerk/Replays kommen

**Wichtig:** Intent kennt keine Objekttypen, keine konkrete Aktion!

### 2. **StateFlags** (Single Source of Truth)
```gdscript
StateFlags:
  controlled: bool    # Vom Puppeteer gesteuert?
  grounded: bool      # Auf Boden?
  alive: bool         # Noch am Leben?
```
- **NICHT FSM** – orthogonale Flags statt State-Explosion
- Motor liest diese, Animation wird davon bestimmt

### 3. **Engine** (Physik)
Physik-Executive:
```
Intent → Engine.apply_intent()
  ↓
velocity berechnen
  ↓
move_and_slide()
  ↓
StateFlags.grounded aktualisieren
```

### 4. **Motor** (Motion/Animation)
Animation-Executive (beobachtet StateFlags):
```
StateFlags.controlled, grounded, velocity
  ↓
Motor.update_animation()
  ↓
Passende Animation wählen
  ↓
AnimationPlayer2D.play()
  ↓
AnimatedSprite2D + Sound-Effekte
```

## 🔄 Ablauf: Player Sitzt auf Stuhl

### 1. Player in Collision Range
```
Chair.Area3D._on_body_entered(player)
chair.candidate_player = player
```

### 2. Player drückt E (Interact)
```
IntentEmitter.collect() → Intent(Type.INTERACT)
Player._physics_process():
  if not controlled:
    engine.apply_intent(intent)  # Normalfall → ignoriert
  # ABER: Intent signalisiert "möchte interagieren"
```

### 3. Objekt reagiert auf Collision + Input
```
Chair._unhandled_input(event):
  if event == "E" and candidate_player:
    player.capture(self)
    play_sit_animation()
    state = "occupied"
```

### 4. Chair steuert
```
Chair.on_intent(intent):
  if intent.type == INTERACT:
    release()

Player.release():
  state.controlled = false
  puppeteer = null
```

## 📋 CODING CONVENTIONS

### Input-Handling
```gdscript
# ✅ RICHTIG: Nur in IntentEmitter
extends Node
class_name IntentEmitter
func collect() -> Array[Intent]:
  if Input.is_action_pressed("move_left"):
    intents.append(Intent.new(Intent.Type.MOVE, ...))
```

```gdscript
# ❌ FALSCH: Input-Handling irgendwo anders
class_name RandomObject
func _unhandled_input(event):
  Input.is_action_pressed("...")  # NEIN!
```

### Intent-Definition
```gdscript
# ✅ RICHTIG: Abstrakt
Intent(Type.MOVE, Vector2(-1, 0))
Intent(Type.INTERACT, null)

# ❌ FALSCH: Konkreter Bezug
Intent(Type.DRINK_COLA, cola_object)
```

### Puppeteer-Implementation
```gdscript
# ✅ RICHTIG
extends Puppeteer
func on_capture(player):
  player.state.controlled = true
  # Chair entscheidet über Ausführung

# ❌ FALSCH
func on_input(event):
  # Puppeteer darf NICHT Input lesen!
```

## 🛠️ NEUE OBJEKTE BAUEN

### Template: Chair (Puppeteer-Objekt)

```gdscript
extends Puppeteer
class_name Chair

@onready var area := $Area3D
@onready var seat_anchor := $SeatAnchor

var occupant: Player = null

func _ready():
  area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
  if body is Player:
    occupant = body

func _unhandled_input(event):
  if event.is_action_pressed("ui_accept") and occupant:
    occupant.capture(self)

func on_capture(player: Player):
  player.engine.lock_movement()
  # Play Animation

func on_intent(intent: Intent):
  if intent.type == Intent.Type.INTERACT:
    release()

func on_release(player: Player):
  player.engine.unlock_movement()
  # Play Stand Animation
  occupant = null
```

### Template: Cola (Attachment-Objekt, kein Puppeteer!)

```gdscript
extends Node3D

func attach_to_player(player: Player):
  reparent(player.$AttachmentSlot)
  # Player bleibt controlled = false
  # Dose kontrolliert sich selbst

func drink():
  # Dose-spezifische Logik
  pass
```

## 🧪 TESTING

Dank StateFlags: Keine Animation mocking nötig!

```gdscript
func test_player_can_jump():
  var can_jump = player.state.grounded and not player.state.controlled
  assert can_jump

func test_player_captured():
  chair.capture(player)
  assert player.state.controlled == true
  assert player.puppeteer == chair
```

## ⚙️ WICHTIGE INVARIANTEN

```
✅ Input IMMER nur in IntentEmitter
✅ Intent IMMER abstrakt (keine Typ-Referenzen)
✅ StateFlags = Single Source of Truth
✅ Puppeteer entscheidet Ausführung, nicht Absicht
✅ Engine führt Intent nur aus wenn !controlled
✅ Animation ist reiner Beobachter
✅ Player kennt KEINE Objekttypen
✅ Objekte kennen KEIN Input-System
```

## 🚀 NÄCHSTE SCHRITTE (für dich)

1. **Chair implementieren** – First Puppeteer-Beispiel
2. **Animation State Machine** – Liest StateFlags/Velocity
3. **Cola/Dose** – Attachment-Beispiel
4. **Main Scene** – Alles zusammenbringen

## � WICHTIGE DATEIEN

- `ARCHITECTURE.md` – Design-Dokumentation für User
- `ADVANCED_CONCEPTS.md` – **NPC-Modell, Possession, komplexe Szenarien**
- `src/player/player.gd` – Core Orchestrator
- `src/puppeteer.gd` – Interface für Objekte
- `project.godot` – Godot Project Config

---

**ZENTRALES KONZEPT:** Ein NPC ist ein Player mit AI-Puppeteer!
Siehe [ADVANCED_CONCEPTS.md](ADVANCED_CONCEPTS.md#-npcs-permanently-puppeteered-players)

---

**Kernprinzip:** Der Player ist eine **Plattform**, nicht ein Zustandsautomat. Objekte sind das **Verhalten**.
