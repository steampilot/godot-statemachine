# Component-Based Architecture

Statt eines großen globalen Systems nutzen wir **Komponenten**, die auf beliebige Nodes geklebt werden können.

## HealthComponent

Kann auf **jede Node** angewendet werden: Player, Enemy, Kiste, Door, etc.

**Exports:**
```gdscript
@export var max_health: int = 100
@export var current_health: int = 100
@export var invulnerable: bool = false
@export var invulnerability_duration: float = 0.0
```

**Methoden:**
```gdscript
take_damage(damage: int)          # Schaden zufügen
restore_health(amount: int)       # Heilen
set_health(value: int)            # Direkt setzen
get_health() -> int               # Aktuelles Health
get_health_percent() -> float     # 0-100%
is_alive() -> bool                # Noch lebendig?
set_invulnerable_for(duration)    # Unverwundbar für X Sekunden
reset()                           # Zurücksetzen
```

**Signals:**
```gdscript
signal health_changed(from_amount: int, damage_amount: int, of_max_amount: int)
signal health_depleted
signal health_restored(amount: int)
```

**Beispiel:**
```gdscript
func _ready():
    health.health_changed.connect(_on_health_changed)
    health.health_depleted.connect(_on_death)

func take_damage(damage: int):
    health.take_damage(damage)

func _on_health_changed(from: int, damage: int, max_hp: int):
    print("Health: %d -> %d / %d" % [from, from - damage, max_hp])

func _on_death():
    queue_free()
```

---

## VelocityComponent

Für **bewegliche Objekte**: Player, Enemy, Projectile, etc.

**Exports:**
```gdscript
@export var direction: Vector2 = Vector2.ZERO
@export var speed: float = 100.0
@export var acceleration: float = 0.0
@export var max_speed: float = 500.0
```

**Methoden:**
```gdscript
set_direction(new_direction: Vector2)  # Richtung setzen
set_speed(new_speed: float)            # Speed setzen
get_velocity() -> Vector2              # Aktuelle Velocity
get_speed() -> float                   # Aktueller Speed
get_direction() -> Vector2             # Normalisierte Richtung
stop()                                 # Bewegung stoppen
accelerate(delta: float)               # Beschleunigen
decelerate(delta: float)               # Verzögern
```

**Signals:**
```gdscript
signal velocity_changed(new_velocity: Vector2)
signal speed_changed(new_speed: float)
```

**Beispiel (Player Input):**
```gdscript
func _process(_delta):
    var move_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity_comp.set_direction(move_vec)
```

---

## PhysicsComponent

Für **Gravitation, Jump, Bewegungsphysik**.

**WICHTIG: Alle Forces sind POSITIV!**
- `jump_force: 100` = Jump nach OBEN (wird intern zu -100 in Godot-Koordinaten)
- `gravity: 980` = Gravitation nach UNTEN (wird intern angewendet)

**Exports:**
```gdscript
@export var gravity: float = 980.0       # Positive Gravitation nach unten
@export var jump_force: float = 0.0      # Positive Jump Force nach oben
@export var max_fall_speed: float = 500.0
@export var use_gravity: bool = true
```

**Methoden:**
```gdscript
jump(force: float)                   # Jump mit POSITIVER Force nach oben
apply_vertical_force(force: float)   # Apply externe Force
get_vertical_velocity() -> float     # Aktuelle Vertical Velocity
is_on_floor() -> bool                # Auf Boden?
is_in_air() -> bool                  # In der Luft?
is_jumping_now() -> bool             # Springt gerade?
stop_vertical_movement()             # Vertical Velocity stoppen
```

**Signals:**
```gdscript
signal jumped(force: float)
signal landed
signal velocity_changed(velocity: Vector2)
```

**Beispiel:**
```gdscript
# Jump mit positiver Force (nach oben)
physics_comp.jump(100.0)  # 100 = nach oben!

# Nicht: physics_comp.jump(-100)  ← Das ist falsch!
```

---

## PushableComponent

Für **schiebbare Objekte**: Kisten, Steine, Blöcke, etc.

**Exports:**
```gdscript
@export var push_force: float = 50.0
@export var friction: float = 0.9       # Bremsfaktor
@export var max_push_speed: float = 200.0
```

**Methoden:**
```gdscript
push(direction: Vector2, force: float)  # Schieben
set_push_velocity(velocity: Vector2)    # Velocity direkt setzen
get_push_velocity() -> Vector2          # Aktuelle Push-Velocity
stop()                                  # Stoppen
get_push_speed_percent() -> float       # Prozentsatz der max Speed
```

**Signals:**
```gdscript
signal pushed(direction: Vector2, force: float)
signal stopped
```

**Beispiel:**
```gdscript
# In Enemy AI oder Player-Interaction
box_node.push(player_direction, 100)
```

---

## Entity-Beispiele

### Enemy
```gdscript
extends CharacterBody2D
class_name Enemy

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent

func take_damage(amount: int) -> void:
    health.take_damage(amount)
```

### Box/Kiste
```gdscript
extends CharacterBody2D
class_name Box

@onready var health: HealthComponent = $HealthComponent
@onready var pushable: PushableComponent = $PushableComponent

func push_box(direction: Vector2, force: float) -> void:
    pushable.push(direction, force)
```

### Player / Platformer
```gdscript
extends CharacterBody2D
class_name Platformer

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent
@onready var physics_comp: PhysicsComponent = $PhysicsComponent

# Jump mit positiver Force!
physics_comp.jump(100.0)  # Nach oben, nicht negativ!
```

---

## Scene Struktur Beispiele

### Enemy (Horizontal Movement)
```
Enemy (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
├── HealthComponent
├── VelocityComponent
└── AnimationPlayer
```

### Platformer (Jump + Horizontal)
```
Platformer (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
├── HealthComponent
├── VelocityComponent
├── PhysicsComponent
├── IntentEmitter
└── AnimationPlayer
```

### Box (Pushable)
```
Box (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
├── HealthComponent
└── PushableComponent
```

---

## Vorteile

✓ **Wiederverwendbar**: Components können auf jede beliebige Node geklebt werden
✓ **Modular**: Einfach neue Components hinzufügen
✓ **Testbar**: Komponenten sind isoliert testbar
✓ **Flexible**: Mix & Match - nicht jedes Objekt braucht alle Components
✓ **Exportierbar**: Parameter sind im Inspector sichtbar & editierbar
