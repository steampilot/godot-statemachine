# Advanced Concepts: Node Hierarchy & Puppeteering

## 🎯 Kernunterschied: Attachment vs. Puppeteering

### 1. Attachment (Ball-Modell)

**Das Objekt wird Teil des Players**

```
BEFORE attach:
World
├── Player
├── Chair
└── Ball 🟡

AFTER attach:
World
├── Player
│   └── AttachmentSlot
│       └── Ball 🟡 ← reparented!
└── Chair
```

**Implementierung:**
```gdscript
# Ball.gd
func attach_to_player(player: Player):
    reparent(player.$AttachmentSlot)  # ← KEY: wird Kind!
    freeze = true                      # ← Physik deaktiviert

func drop_at(position: Vector2):
    reparent(get_tree().root.get_child(...))  # ← Zurück zu World
    freeze = false                             # ← Physik aktiv
```

**Charakteristiken:**
- ✅ Objekt wird in Scene Tree **neu gehängt**
- ✅ Objekt verliert eigene Physik (wenn attached)
- ✅ Objekt folgt Player **automatisch** (Hierarchie)
- ✅ Sichtbar: `ball.get_parent().name == "AttachmentSlot"`

**Use Cases:**
- Gegenstände tragen (Waffen, Dose, Schlüssel)
- Zusammengesetzte Objekte
- Inventar-Items

---

### 2. Puppeteering (Chair-Modell)

**Das Objekt kontrolliert den Player, bleibt aber eigenständig**

```
ALWAYS:
World
├── Player 🔵 ← bleibt HIER!
├── Chair 🪑
└── Ball 🟡

Auch während Capture:
World
├── Player 🔵 (occupant=true, puppeteer=chair)
├── Chair 🪑 (occupant=player_ref)
└── Ball 🟡
```

**Implementierung:**
```gdscript
# Chair.gd
func on_capture(player: Player):
    occupant = player  # ← Nur Referenz, keine Reparent!
    player.puppeteer = self
    player.controlled = true
    # Position-Sync:
    player.global_position = $SeatAnchor.global_position

func on_intent(intent: Intent):
    # Chair entscheidet über Ausführung
    if intent.type == INTERACT:
        release()
```

**Charakteristiken:**
- ✅ Player bleibt eigenständig in Scene Tree
- ✅ Player behält volle **Identität & Ownership**
- ✅ Chair manipuliert nur **Position & Input-Routing**
- ✅ Player bewegt sich immer noch selbst (engine.physics_tick)
- ✅ Sichtbar: `player.get_parent().name == "TestScene"` (immer!)

**Use Cases:**
- Interaktive Objekte (Stühle, Türen, Terminal)
- Fahrzeuge
- Plattformen
- NPCs die Player kontrollieren

---

## 🚗 Extended Use Case: Das Auto-Szenario

### Scenario: Player steigt ins Auto

**Das Auto ist komplexer - auch ein CharacterBody2D mit Engine!**

```gdscript
# Car.gd
extends CharacterBody2D
class_name Car

var occupant: Player = null

func on_capture(player: Player):
    occupant = player
    player.controlled = true
    player.puppeteer = self
    # Sync
    player.global_position = $DriverSeat.global_position

func on_intent(intent: Intent):
    # Auto interpretiert MOVE anders als Player!
    if intent.type == Intent.Type.MOVE:
        # Player wollte MOVE
        # Auto macht aus MOVE: "fahre in die Richtung"
        velocity.x = intent.value.x * car_speed
        velocity.y = intent.value.y * car_speed

func _physics_process(delta):
    # Auto hat eigene Physik
    velocity.y += gravity * delta
    move_and_slide()

    # Occupant wird mitgezogen
    if occupant:
        occupant.global_position = $DriverSeat.global_position
```

**Scene Tree:**
```
World
├── Player 🔵 (controlled=true, puppeteer=car)
│   └── AttachmentSlot
│       └── Ball 🟡 (occupant hält Ball!)
└── Car 🚗 (occupant=player_ref)
```

**Ablauf:**
1. Player drückt E nahe Auto
2. `car.on_capture(player)` → Player wird kontrolliert
3. Player drückt Links
4. IntentEmitter sendet `Intent(MOVE, (-1, 0))`
5. `car.on_intent(intent)` → Auto acceleriert nach links
6. Auto macht `move_and_slide()` und zieht sich selbst
7. Player-Position wird synced → `player.global_position = car_seat`
8. Player drückt E nochmal
9. `car.release()` → Player ist wieder frei

**Wichtig:** Player ist während Fahrt immer noch CharacterBody2D mit eigenem move_and_slide(), aber:
- Seine Input-Intents werden ignoriert
- Seine Position wird vom Auto bestimmt
- Seine Physics-Tick läuft, aber hat keine Wirkung

---

## 🎨 Vergleich: Attachment vs. Puppeteering

| Aspekt | Attachment (Ball) | Puppeteering (Chair) |
|--------|-------------------|---------------------|
| **Scene Tree Reparent** | ✅ JA | ❌ NEIN |
| **Bleibt eigenständig** | ❌ NEIN | ✅ JA |
| **Verfügt über Identität** | ❌ (temporär) | ✅ (immer) |
| **Eigenständige Physik** | ❌ (disabled) | ✅ (Player behält sie) |
| **Input-Routing** | ❌ (ignoriert) | ✅ (Chair entscheidet) |
| **Netzwerk-Ownership** | 🔄 Komplex | ✅ Klar (Player) |
| **Savegame-sicher** | 🔄 Komplex | ✅ (Player bleibt Entity) |
| **Use Case** | Gegenstände tragen | Fahrzeuge, Plattformen |

---

## 🧠 Design-Prinzipien

### 1. Attachment = Komposition
```
Player ist Zusammensetzung:
  Body + Waffe + Schild + Rucksack
```

### 2. Puppeteering = Delegation
```
Player bleibt Player
Auto wird nur temporär "Manager"
```

### 3. Beide sind orthogonal!
```gdscript
# Scenario: Player im Auto mit Ball

World
├── Player 🔵
│   └── AttachmentSlot
│       └── Ball 🟡 (attached!)
└── Car 🚗 (occupant=player, puppeteer)

# Player kann:
# - Ball fallen lassen (Ball.drop_at)
# - Auto verlassen (car.release)
# - Ball tragen UND im Auto fahren
```

---

## 🚀 Design Scalability

**Mit diesem System ist ALLES möglich:**

```gdscript
# Einfache Objekte
Chair extends Puppeteer        # ✅ Funktioniert
Ladder extends Puppeteer       # ✅ Funktioniert

# Komplexe Objekte
Car extends CharacterBody2D    # ✅ Funktioniert
  - Eigene Engine
  - Eigene StateFlags
  - Eigene Physik

Dragon extends CharacterBody2D # ✅ Funktioniert
  - Kann fliegen
  - Hat AI
  - Player sitzt darauf

Spaceship extends Node2D       # ✅ Funktioniert
  - Komplexe Multi-Player-Kontrolle
  - Astronauten-Physics
```

**Ein Puppeteer-Objekt kann beliebig komplex sein** - das Interface bleibt immer gleich:
```gdscript
func on_capture(player: Player)
func on_intent(intent: Intent)
func on_release(player: Player)
```

---

## 📝 Merksätze

```
Attachment:
  "Das Objekt wird Teil des Players"

Puppeteering:
  "Das Objekt kontrolliert den Player"

Auto:
  "Das Auto ist ein komplexer Puppeteer"
  "Player sitzt drin und wird kontrolliert"
  "Aber Player bleibt eigenständige Entity"
```

---

## 🎯 Praktische Implementierungs-Checkliste

### Wenn du ein neues Objekt baust:

**Frage 1: Wird das Objekt am Player befestigt?**
- ✅ JA → Attachment (wie Ball)
- ❌ NEIN → weiter zu Frage 2

**Frage 2: Kontrolliert das Objekt den Player?**
- ✅ JA → Puppeteer (wie Chair, Auto)
- ❌ NEIN → Normale Entität (wie Gegner)

**Frage 3: Ist das Objekt selbst komplex (Physik, Animation)?**
- ✅ JA → Extend CharacterBody2D, implementiere Puppeteer
- ❌ NEIN → Extend Node2D, implementiere Puppeteer

---

## 🔗 Weiterführende Beispiele

Siehe:
- [ARCHITECTURE.md](ARCHITECTURE.md) – Design-Überblick
- [src/objects/chair.gd](src/objects/chair.gd) – Einfacher Puppeteer
- [src/objects/ball.gd](src/objects/ball.gd) – Attachment-Objekt

---

## 🤖 NPCs: Permanently Puppeteered Players

### Das elegante NPC-Modell

**Ein NPC ist NICHT eine separate Klasse - es ist ein Player mit AI-Puppeteer!**

```gdscript
# NPC.gd - Kann auch "class_name NPC extends Player" sein!
extends CharacterBody2D

var ai_controller: Node

func _ready():
    engine.setup(self, state)

    # Der Unterschied zum Player: AI ist immer der Puppeteer
    ai_controller = $AIController
    state.controlled = true      # ← IMMER TRUE
    puppeteer = ai_controller    # ← IMMER GESETZT

func _physics_process(delta):
    # Keine Input-Verarbeitung!
    # Stattdessen: AI generiert Intents
    var intents = ai_controller.generate_intents()

    for intent in intents:
        ai_controller.on_intent(intent)

    engine.physics_tick(delta)
```

### Vergleich: Player vs. NPC

| Aspekt | Player | NPC |
|--------|--------|-----|
| **Klasse** | CharacterBody2D | CharacterBody2D (identisch!) |
| **Intent-Quelle** | Input (Tastatur) | AI-Algorithm |
| **controlled** | `false` (default) | `true` (always) |
| **puppeteer** | `null` (default) | `ai_controller` (always) |
| **Move-and-slide** | Selbst steuerbar | AI steuert |
| **Kann mit Objekten interagieren** | ✅ JA | ✅ JA |
| **Kann vom Player kontrolliert werden** | ❌ NEIN | ✅ JA (besessen)! |

### Warum das brillant ist

**Kein separater NPC-Code nötig!**

```gdscript
# ❌ FALSCH - Old School:
class_name Player
    func move() ...
    func animate() ...

class_name NPC
    func move() ...     # Duplikat!
    func animate() ...  # Duplikat!

# ✅ RICHTIG - Mit unserem System:
class_name CharacterBase
    - state.controlled
    - puppeteer
    - intent_emitter
    - engine
    - animate()

# Player nutzt IntentEmitter
# NPC nutzt AI als Puppeteer
# Beide nutzen IDENTISCHE Engine/Animation-Logik
```

### Szenarien mit NPCs

#### Szenario 1: NPC geht normale Route

```
World
├── Player 🔵 (controlled=false, puppeteer=null)
└── NPC_Guard 🟠 (controlled=true, puppeteer=ai_patrol)

# NPC läuft autonom, reagiert auf AI-Befehle
```

#### Szenario 2: Player kontrolliert NPC (Possession)

```
World
├── Player 🔵 (controlled=true, puppeteer=possession_controller)
└── NPC_Guard 🟠 (occupied=player)

# Player gibt Input → IntentEmitter
# possession_controller leitet zu NPC weiter
# NPC folgt Player-Input
```

#### Szenario 3: NPC und Player zusammen auf Vehicle

```
World
├── Player 🔵 (controlled=true, puppeteer=car)
│   └── AttachmentSlot
│       └── Ball 🟡
├── NPC_Passenger 🟠 (controlled=true, puppeteer=car)
└── Car 🚗 (occupants=[player, npc])

# Beide sind controlled vom Car
# Car entscheidet über beide
```

#### Szenario 4: NPC sitzt auf Chair

```
World
├── Player 🔵
├── NPC_Guard 🟠 (controlled=true, puppeteer=ai_patrol)
└── Chair 🪑

# NPC sieht Chair über AI-Logik
# chair.capture(npc)
# npc.puppeteer = chair  # ← Puppeteer wechselt!
# npc.controlled = true  # ← Bleibt true
# Chair entscheidet jetzt

# chair.release(npc)
# npc.puppeteer = ai_patrol  # ← Zurück zur AI
```

### Entwicklungsrichtung

Mit diesem NPC-Modell können wir:

1. **AI-Layer bauen** (separate von Player-Physik)
   - Pathfinding
   - Behavior Trees
   - State Machines für Verhalten

2. **Possession-Mechanic implementieren**
   - Player übernimmt NPC
   - NPC wird vom Player gesteuert
   - Puppet-Master Gameplay

3. **Multi-Entity Szenen**
   - Viele NPCs gleichzeitig
   - Jedem eigene AI
   - Alle nutzen gleiche Physics-Engine

4. **Networked NPCs** (Multiplayer)
   - NPCs mit Network-Puppeteer
   - Server ist authoritative
   - Clients syncen Intents

### Template: Einfacher NPC mit Patrol-AI

```gdscript
# NPCPatrol.gd
extends CharacterBody2D
class_name NPCPatrol

@onready var engine: Engine = $Engine
@onready var state: StateFlags = $StateFlags
@onready var ai: PatrolAI = $PatrolAI

func _ready():
    engine.setup(self, state)
    state.controlled = true
    puppeteer = ai

func _physics_process(delta):
    var intents = ai.generate_intents()

    for intent in intents:
        ai.on_intent(intent)

    engine.physics_tick(delta)
```

```gdscript
# PatrolAI.gd
extends Puppeteer
class_name PatrolAI

var patrol_points: Array
var current_index: int = 0
var npc: CharacterBody2D

func _ready():
    npc = get_parent()

func generate_intents() -> Array[Intent]:
    var intents: Array[Intent] = []

    var target = patrol_points[current_index]
    var direction = (target - npc.global_position).normalized()

    if direction.x > 0.1:
        intents.append(Intent.new(Intent.Type.MOVE, Vector2(1, 0)))
    elif direction.x < -0.1:
        intents.append(Intent.new(Intent.Type.MOVE, Vector2(-1, 0)))

    if npc.global_position.distance_to(target) < 10:
        current_index = (current_index + 1) % patrol_points.size()

    return intents

func on_intent(intent: Intent):
    # Wird vom NPC aufgerufen
    pass
```

---

## 🔗 Weiterführende Beispiele

Siehe:
- [ARCHITECTURE.md](ARCHITECTURE.md) – Design-Überblick
- [src/objects/chair.gd](src/objects/chair.gd) – Einfacher Puppeteer
- [src/objects/ball.gd](src/objects/ball.gd) – Attachment-Objekt
