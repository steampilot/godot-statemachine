# KillZone - Fallzone unten am Bild

## Konzept

Eine **KillZone** ist eine unsichtbare Fläche unten am Bild (oder an beliebigen Orten), die:
- ✓ **Player respawnt** bei Respawn-Position mit vollem Health
- ✓ **Enemies** werden durch Death-Sequenz gelöscht
- ✓ **Objekte** (Kisten, etc.) werden gelöscht

## KillZone.gd

```gdscript
class_name KillZone
extends Area2D

@export var respawn_position: Vector2 = Vector2.ZERO
@export var player_respawn_health: int = 100

signal entity_fell(entity: Node)
signal player_respawned
```

**Exports:**
- `respawn_position` - Wo der Player respawnt (automatisch auf KillZone Position)
- `player_respawn_health` - Mit wie viel HP der Player respawnt

**Methoden:**
```gdscript
set_respawn_position(pos: Vector2)  # Respawn-Position setzen
get_respawn_position() -> Vector2   # Respawn-Position abrufen
```

**Signals:**
```gdscript
signal entity_fell(entity: Node)     # Wenn etwas in Zone fällt
signal player_respawned              # Wenn Player respawned
```

---

## Scene Aufbau

```
KillZone (Area2D) - Script: KillZone.gd
├── CollisionShape2D (RectangleShape2D - groß!)
└── VisualDebug (ColorRect - rot, halbtransparent)
```

Die **VisualDebug** ColorRect ist optional - zum Debuggen sichtbar:
- Rot = KillZone
- Halb-transparent = nicht störend

---

## Verwendung in Level

### Klassischer Setup:
```
Level (Node2D)
├── TileMap
├── Player
├── Enemy_1
├── Enemy_2
├── Box
└── KillZone (ganz unten am Bild)
```

### In Code:
```gdscript
# KillZone wird automatisch konfiguriert
# respawn_position = Position der KillZone (oder manuell setzen)

# Im Spiel:
# - Player fällt unten raus
#   → KillZone.entity_fell emittiert
#   → Player respawnt an respawn_position
#   → Health = 100
#   → player.reset_player() wird aufgerufen

# - Enemy fällt unten raus
#   → DeathComponent.handle_death() wird aufgerufen
#   → Enemy wird gelöscht (queue_free)
```

---

## Advanced: Multiple Spawn Points

```gdscript
# Wenn du mehrere Spawn-Punkte brauchst:

@onready var spawn_points = [
    Vector2(100, 100),    # Spawn 1
    Vector2(800, 100),    # Spawn 2
    Vector2(1500, 100),   # Spawn 3
]

var current_spawn_idx = 0

func respawn_at_next_spawn() -> Vector2:
    var spawn = spawn_points[current_spawn_idx]
    current_spawn_idx = (current_spawn_idx + 1) % spawn_points.size()
    return spawn
```

---

## Checkpoint System

KillZone kann auch als **Checkpoint** erweitert werden:

```gdscript
# KillZone.gd erweitert:

@export var checkpoint_id: String = "spawn_main"

func set_as_checkpoint() -> void:
    # Speichert diese Position als letzten Checkpoint
    LEVEL_LOADER.set_last_checkpoint(checkpoint_id, respawn_position)

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        set_as_checkpoint()  # Checkpoint speichern
```

---

## Debug Tipps

**VisualDebug sichtbar machen:**
- Projekt starten
- KillZone sollte als rotes Rechteck unten sichtbar sein
- Wenn nicht: Position checken, CollisionShape2D überprüfen

**Respawn testen:**
```gdscript
# In _ready des Levels:
var kill_zone = $KillZone
print("KillZone respawn at: %s" % kill_zone.respawn_position)
print("Player will respawn with %d HP" % kill_zone.player_respawn_health)
```

---

## Best Practices

✓ **KillZone breiter als Level-Breite** - mindestens 100px unter Level
✓ **Respawn-Position oberhalb der KillZone** - oder auf Spawn-Plattform
✓ **player_respawn_health** entsprechend setzen
✓ **VisualDebug in Release deaktivieren** - `visible = false`
✓ **Pro Level maximal eine KillZone** - am unteren Rand
