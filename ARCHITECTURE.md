# State Machine Architecture Guide

## 📋 Projektstruktur

```
src/
├── player/              # Player-System (Core)
│   ├── player.gd       # Orchestrator
│   ├── motor.gd        # Physik + Bewegung
│   ├── state_flags.gd  # Wahrheitsschicht
│   ├── intent.gd       # Abstrakte Intents
│   ├── intent_emitter.gd # Input → Intent
│   └── player.tscn     # Player-Szene
├── objects/            # Interaktive Objekte
│   ├── chair.gd        # Beispiel-Puppeteer
│   └── ...
├── puppeteer.gd        # Basis-Interface
└── scenes/             # Hauptszenen
    └── main.tscn
```

## 🎯 Kernkonzepte

### 1. Intent-System (Input-unabhängig)

```
Input → IntentEmitter → Intent
```

- **Input nur im Player** (IntentEmitter.gd)
- **Intents sind abstrakt** (keine Objekt-Referenzen)
- **Intents können von überall kommen**: Input, AI, Netzwerk, Replays

### 2. Puppeteering (temporäre Kontrolle)

```
Player (Free) → [Interaction] → Puppeteer (Controlled)
```

- Objekte übernehmen temporär den Player
- Player behält Identität (Position, ID, Ownership)
- Cleanups automatisch beim Release

### 3. Flag-basierte States (nicht FSM)

```gdscript
StateFlags:
  - controlled: bool     # Vom Puppeteer gesteuert
  - grounded: bool       # Berührt Boden
  - alive: bool          # Noch am Leben
```

**Vorteil:** Orthogonal, keine State-Explosion, kombinierbar

### 4. Architektur-Schichten

```
Layer 1: Intent (Absicht)
Layer 2: Motor (Physik)
Layer 3: StateFlags (Wahrheit)
Layer 4: Animation (Beobachter - nur Darstellung)
```

## 🔄 Interaktions-Ablauf: Stuhl-Beispiel

### 1. Player nähert sich
```
Chair.Area3D.body_entered(player)
Chair speichert player als candidate
```

### 2. Player drückt E (Interact)
```
IntentEmitter.collect() → Intent(INTERACT)
Player.on_physics_process():
  if controlled and puppeteer:
    puppeteer.on_intent(intent)
  else:
    player.capture(chair)
```

### 3. Capture
```
player.capture(chair):
  state.controlled = true
  puppeteer = chair
  chair.on_capture(player)
```

### 4. Chair steuert
```
chair.on_intent(intent):
  if intent.type == INTERACT:
    chair.release()
```

### 5. Release
```
chair.release():
  player.release()
  player.state.controlled = false
  player.puppeteer = null
```

## 🎨 Sprite-Override-Modell (für 2D)

```
Während Capture:
  Player-Sprite wird hidden
  Object-Sprite wird an Player-Position gerendert
  Sync mit Player-Animation basierend auf Frame
```

## 📦 Attachment-System

```
Player bleibt Free
Objekt (Dose) bindet sich an AttachmentSlot
Player weiß nicht, was am Slot hängt
Objekt steuert seine Darstellung
```

## 🔧 Wie du neue Objekte baust

### Beispiel: Chair (Puppeteer)

```gdscript
extends Puppeteer

func on_capture(player):
  # Chair übernimmt Player
  player.motor.lock_movement()
  play_sit_animation()

func on_intent(intent):
  if intent.type == Intent.Type.INTERACT:
    release()

func on_release(player):
  player.motor.unlock_movement()
  play_stand_animation()
```

### Beispiel: Dose (Attachment)

```gdscript
extends Node3D

func attach_to_player(player):
  reparent(player.$AttachmentSlot)
  # Player bleibt Free - Dose kontrolliert sich selbst

func use():
  # Dose-spezifische Logik
  pass
```

## ⚙️ Wichtige Invarianten

```
✓ Input immer nur im Player
✓ Intent immer abstrakt
✓ Puppeteer entscheidet Ausführung
✓ Player kennt keine Objekt-Typen
✓ Objekte kennen kein Input-System
✓ StateFlags sind Single Source of Truth
✓ Animation ist nur Beobachter
```

## 🧪 Testing

StateFlags ermöglichen isoliertes Testing ohne Animation zu mocken:

```gdscript
func test_grounded():
  assert player.state.grounded == true

func test_can_jump():
  var can_jump = player.state.grounded and not player.state.controlled
  assert can_jump
```

## 🚀 Multiplayer-Fähig

```
Puppeteering funktioniert über Netzwerk:
- Objekt ist authoritative
- Client sendet Intent
- Server entscheidet Ausführung
- Sync über StateFlags
```

## 🤖 NPC-Integration

Ein NPC ist ein Player mit `controlled = true` und eine AI als Puppeteer:

```gdscript
npc.puppeteer = ai_controller
ai_controller.on_capture(npc)
```

Kein separater NPC-Code nötig.

## 📝 Code-Style

- **GDScript**: Tabs (1 Tab = 1 Level)
- **Klassen**: class_name am Anfang
- **Kommentare**: ## für Public API, # für internal
- **Naming**: snake_case für alles

## 🔗 Wichtige Klassen

| Klasse | Zweck |
|--------|-------|
| Player | Orchestrator |
| Motor | Physik-Exekutive |
| StateFlags | Wahrheitsschicht |
| Intent | Abstrakte Absicht |
| IntentEmitter | Input → Intent |
| Puppeteer | Basis für controllable Objekte |

---

**Wichtigster Merkatz:** Der Player ist eine Plattform. Objekte sind Verhalten.
