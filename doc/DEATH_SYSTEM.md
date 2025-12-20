# Death Handling System

## Konzept

**Separation of Concerns:**
- `HealthComponent` = nur Health kümmern, Signal emittieren
- `DeathComponent` = Death-Sequenz handeln (Animation, Effects, etc.)
- Entity (Player/Enemy) = auf Signals reagieren

**Player spezial:**
- ❌ **NIE** `queue_free()`
- Camera, AudioListener, etc. müssen erhalten bleiben
- Mit `reset_player()` kann er neu gestartet werden

**Enemy/Box:**
- ✅ **OK** `queue_free()` nach Death
- `DeathComponent.auto_queue_free = true`

---

## DeathComponent

Jede Entity mit `HealthComponent` sollte auch `DeathComponent` haben.

**Exports:**
```gdscript
@export var death_animation_duration: float = 1.0
@export var auto_queue_free: bool = false       # FALSE für Player!
@export var on_death_callback: Callable = Callable()
```

**Methoden:**
```gdscript
handle_death()              # Death-Sequenz starten
trigger_death()             # Manuell Death triggern
is_dead_check() -> bool     # Ist tot?
```

**Signals:**
```gdscript
signal death_started
signal death_finished
```

---

## Player.gd (neu: nicht PlayerEntity.gd)

**WICHTIG:**
```gdscript
class_name Player

# NIEMALS:
# queue_free()
# die()
# destroy()

# Stattdessen: DeathComponent handelt alles
death_comp.death_started.connect(_on_death_started)
death_comp.death_finished.connect(_on_death_finished)
```

**Resetting:**
```gdscript
player.reset_player()  # Health reset, re-enable input, etc.
```

---

## Beispiel Scene Struktur

### Player (CharacterBody2D) - **BLEIBT BESTEHEN**
```
Player
├── Camera2D (PRESERVED!)
├── AudioStreamPlayer (PRESERVED!)
├── CollisionShape2D
├── Sprite2D
├── HealthComponent
├── VelocityComponent
├── PhysicsComponent
├── DeathComponent (auto_queue_free = false)
├── IntentEmitter
└── AnimationPlayer
```

### Enemy (CharacterBody2D) - **queue_free OK**
```
Enemy
├── CollisionShape2D
├── Sprite2D
├── HealthComponent
├── VelocityComponent
├── DeathComponent (auto_queue_free = true)
└── AnimationPlayer
```

### Box (CharacterBody2D) - **queue_free OK**
```
Box
├── CollisionShape2D
├── Sprite2D
├── HealthComponent
├── PushableComponent
├── DeathComponent (auto_queue_free = true)
└── ParticleSystem
```

---

## Death Flow

```
Entity nimmt Schaden
    ↓
HealthComponent.take_damage()
    ↓
current_health <= 0?
    ↓
Signal: health_depleted.emit()
    ↓
DeathComponent._on_health_depleted()
    ↓
DeathComponent.handle_death()
    ↓
death_animation_duration warten
    ↓
Signal: death_finished.emit()
    ↓
auto_queue_free = true?
    ├─ JA → queue_free()
    └─ NEIN → _disable_entity() (nur Fade, kein Delete)
```

---

## Best Practices

✓ **Immer DeathComponent verwenden** - nicht direkt queue_free
✓ **Player.reset_player()** - für Respawn
✓ **auto_queue_free = true** nur für disposable Entities
✓ **Callbacks** für Custom Death-Effekte definieren
✓ **on_death_callback** für Spezial-Logik

---

## Code Beispiele

### Player Death Handling
```gdscript
# Player.gd
@onready var death_comp: DeathComponent = $DeathComponent

func _on_health_depleted() -> void:
    # DeathComponent handelt alles!
    # Wir reagieren nur
    pass

func _on_death_started() -> void:
    print("Death animation starting...")
    # HUD "Game Over" anzeigen

func _on_death_finished() -> void:
    print("Death animation finished")
    # Respawn Menu zeigen
    # ABER: Player Node existiert noch!

# Bei Respawn:
player.reset_player()
```

### Enemy Death
```gdscript
# Enemy.gd
@onready var death_comp: DeathComponent = $DeathComponent

func _ready() -> void:
    death_comp.auto_queue_free = true  # Enemy wird gelöscht

func _on_death_started() -> void:
    # Ragdoll, Explosion, etc.
    pass
```

### Custom Death Callback
```gdscript
# In _ready():
death_comp.on_death_callback = func():
    print("Custom death logic!")
    AUDIO.play_sfx("res://audio/explosion.wav")
    spawn_particles()
```
