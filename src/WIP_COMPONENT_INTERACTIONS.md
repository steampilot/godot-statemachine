# WIP: Component-Based Enemy/Player Interactions

## Konzept
Verwende HealthComponent und VelocityComponent für saubere, modulare Interaktionen zwischen Player und Enemies.

## Aktueller Status
- ✅ HealthComponent existiert bereits
- ✅ VelocityComponent existiert bereits
- ⏳ Integration in Enemy/Player-Interaktionen steht aus

## Geplante Implementierung

### Enemy Setup
```gdscript
# Enemy mit Area2D Sensoren
# - VerticalSensor (oben auf Kopf)
# - HorizontalSensor (Seiten)

func _on_vertical_sensors_body_entered(body):
    # Wenn Player auf Enemy springt
    if body.has_node("VelocityComponent"):
        body.get_node("VelocityComponent").add_impulse(Vector2(0, -500))
    queue_free()  # Enemy stirbt

func _on_horizontal_sensors_body_entered(body):
    # Wenn Player Enemy von der Seite berührt
    if body.has_node("HealthComponent"):
        body.get_node("HealthComponent").take_damage(1)
```

### Player Setup
```gdscript
# Player mit Komponenten als Child Nodes:
# - HealthComponent
# - VelocityComponent

# Komponenten können von außen angesteuert werden
# Keine direkte Manipulation von body.health oder body.velocity
```

## Vorteile
- ✅ Modular und wiederverwendbar
- ✅ Testbar
- ✅ Keine direkte Kopplung zwischen Entities
- ✅ Klare Verantwortlichkeiten

## Enemy Pattern: Snail mit RayCast Edge Detection
```gdscript
extends CharacterBody2D

@export var floor_raycast: RayCast2D
@export var gravity: float = 100

var vel: Vector2
var speed = 40

func _ready():
    vel.x = -speed

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        vel.y += gravity * delta
    else:
        vel.y = 0
    
    # Richtung ändern bei Wand oder Plattform-Ende
    if is_on_wall() or (is_on_floor() and not floor_raycast.is_colliding()):
        vel.x = vel.x * -1  # Velocity umkehren
        floor_raycast.position.x *= -1.0  # RayCast Position umkehren
        $AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h  # Sprite flippen
    
    velocity = vel
    move_and_slide()
    
    $AnimatedSprite2D.play("walk")
```

**Snail Setup:**
- RayCast2D zeigt nach unten (vor dem Enemy)
- Wenn RayCast nichts trifft = Plattform-Ende → umdrehen
- Bei Wand-Kollision → umdrehen

## Area2D Sensor Pattern
```gdscript
# Enemy Node-Struktur:
Enemy (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D (für Physik)
├── RayCast2D (für Edge Detection)
├── HorizontalSensors (Area2D)
│   └── CollisionShape2D
└── VerticalSensors (Area2D)
    └── CollisionShape2D
```

**VerticalSensor** (oben, flach):
- Erkennt wenn Player auf Enemy springt
- → Enemy stirbt, Player bekommt Bounce

**HorizontalSensor** (Seiten, hoch):
- Erkennt wenn Player Enemy von der Seite berührt
- → Player verliert Health

## Nächste Schritte
1. VelocityComponent mit `add_impulse()` Methode erweitern
2. HealthComponent mit `take_damage()` Methode erweitern
3. Enemy Area2D Sensoren implementieren
4. Player Komponenten hinzufügen
5. Snail Enemy mit RayCast + Sensoren testen

## Verwandte Dateien
- [HealthComponent.gd](components/HealthComponent.gd)
- [VelocityComponent.gd](components/VelocityComponent.gd)
- [Enemy.gd](entities/Enemy.gd)
- [Player.gd](entities/Player.gd)

## Zusätzliche Ideen für später
- Signal-basierte Kommunikation (HealthComponent.died, etc.)
- Boss mit Inverse Kinematik / Marionetten-Mechanik
- Fäden durchtrennen für Ragdoll-Physik
