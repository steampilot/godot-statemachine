# GGC INSPIRATION: KNOCKBACK ALS KERN-MECHANIC

## Überblick

**GGC = Gutsy-Gust Chaos** (inspiriert von "Blut & Teef"). In diesem Design-Framework ist **Knockback nicht sekundär** (wie in vielen Spielen), sondern die **primäre Kern-Mechanic** des Combat-Systems.

Gegner fliegen nicht einfach zurück—sie **colliden mit Wänden, Objekten, anderen Gegnern**, erzeugen **Chain-Reactions**, führen zu **Umwelt-Interaktionen** und schaffen **visuelles Chaos**, das **befriedigend und skill-basiert** ist.

---

## Philosophie: Knockback First Design

### Warum Knockback primär ist

In traditionellen Spielen:
- **Damage** ist Primary (Gegner-HP senken)
- **Knockback** ist Sekundär (Cool-Effekt, aber nicht notwendig)

In CapricaGame (GGC Inspiration):
- **Knockback** ist Primary (Gegner-Position ändern)
- **Damage** ist Sekundär (HP senken)
- **Knockback erzeugt Spacing** → Neue Combat-Möglichkeiten

**Warum?** Knockback **sichtbar** ist. Ein Gegner, der 500px fliegt und gegen eine Wand kracht, ist **spektakulär**. Ein Gegner, der 5 HP verliert, ist nicht-sichtbar. Menschen fühlen sich zu sichtbarem Feedback.

### Gameplay-Impact

Knockback-fokussiertes Design bedeutet:

```
Player Attack → Knockback → Enemy fliegt → Collide mit Wand/Objekt/Enemy
                                          ↓
                                    Chain-Reaction
                                    (weitere Gegner pushen)
                                          ↓
                                    Umwelt-Interaktion
                                    (Objekt fällt, Wand bricht)
                                          ↓
                                    Multiple Enemies fliegen
                                          ↓
                                    Visual CHAOS
                                    (befriedigend, laut)
```

---

## Knockback Mechaniken

### Knockback-Berechnung

```gdscript
# res/physics/knockback_system.gd

extends Node
class_name KnockbackSystem

# Base knockback values (pixels per second)
var knockback_base: Dictionary = {
    "punch": 100.0,
    "kick": 250.0,
    "finisher": 400.0,
    "dash": 150.0
}

func calculate_knockback(attack_type: String, source_pos: Vector2, target_pos: Vector2) -> Vector2:
    # Direction from source to target
    var direction = (target_pos - source_pos).normalized()

    # Base force
    var force = knockback_base.get(attack_type, 100.0)

    # Apply multipliers
    var combo_multiplier = 1.0 + (combo_system.get_combo_count() - 1) * 0.3
    var rhythm_multiplier = 1.5 if is_rhythm_perfect() else 1.0

    var final_force = force * combo_multiplier * rhythm_multiplier

    return direction * final_force

func apply_knockback(target: Node2D, knockback_force: Vector2) -> void:
    # Set target velocity to knockback force
    target.velocity = knockback_force

    # Mark as "in flight" for physics
    target.is_knockback_flying = true

    # Trigger knockback animation
    target.play_animation("knockback_flying")

    # Visual effect
    _create_knockback_trail(target.global_position, knockback_force)
```

### Knockback Tiers

Unterschiedliche Attack-Stärken führen zu unterschiedlichen Effekten:

```
Light Knockback (100 px/s):
  - Gegner slides backwards
  - Falls softer (no wall collision effect)
  - Schnelle Recover

Medium Knockback (250 px/s):
  - Gegner flies backwards
  - Höhere Chance wall collision
  - Längere Recover

Heavy Knockback (400+ px/s):
  - Gegner LAUNCHED wie ein Geschoss
  - Wall collision erzeugt großen Effekt
  - Gegner ist temporär incapacitated
```

---

## Wall & Object Collisions

### Wall Collision Effects

Wenn ein Gegner mit einer Wand kollidiert:

```gdscript
# res/entities/Enemy.gd

func _on_collision(collision: KinematicCollision2D) -> void:
    if not is_knockback_flying:
        return

    # Get collision info
    var collider = collision.get_collider()
    var impact_speed = velocity.length()

    # Determine impact intensity
    var intensity = impact_speed / 500.0  # Normalize to 0.0-1.0 for heavy knockback
    intensity = clamp(intensity, 0.0, 1.0)

    # Stop knockback movement
    velocity = Vector2.ZERO
    is_knockback_flying = false

    # Wall impact effects
    _create_wall_impact_vfx(collision.get_position(), intensity)
    _play_wall_impact_sfx(intensity)
    _shake_camera(intensity)

    # Stun effect (can't act for duration based on impact)
    var stun_duration = 0.2 * intensity
    apply_stun(stun_duration)

func _create_wall_impact_vfx(impact_pos: Vector2, intensity: float) -> void:
    # Particle burst
    var particles = preload("res://Scenes/Effects/WallImpact.tscn").instantiate()
    get_parent().add_child(particles)
    particles.global_position = impact_pos
    particles.emitting = true

    # Screen flash
    var flash_intensity = intensity * 0.5
    get_viewport().get_node("Camera2D").flash(Color.WHITE, flash_intensity, 0.1)

    # Crack effect on wall
    if intensity > 0.6:
        create_wall_crack(impact_pos)

func _play_wall_impact_sfx(intensity: float) -> void:
    # Sound varies by intensity
    if intensity < 0.3:
        Audio.play_sfx("impact_light")
    elif intensity < 0.7:
        Audio.play_sfx("impact_medium")
    else:
        Audio.play_sfx("impact_heavy")
```

### Object Collision Chains

Wenn Gegner mit **anderen Objekten** kollidieren:

```gdscript
# res/physics/pushable_object.gd

extends Node2D
class_name PushableObject

@export var mass: float = 1.0  # Resistance to knockback
@export var push_multiplier: float = 0.8  # How much knockback to transfer

var velocity: Vector2 = Vector2.ZERO
var is_falling: bool = false

func on_hit_by_knockback(knockback_force: Vector2) -> void:
    # Object absorbs some knockback based on mass
    var absorbed_force = knockback_force / mass

    # Apply to object
    velocity = absorbed_force * push_multiplier

    # Play animation
    play_animation("falling")
    is_falling = true

    # Particles
    _create_dust_cloud()

    # Sound
    Audio.play_sfx("object_pushed", velocity.length() / 200.0)  # Pitch varies by force

func _process(delta: float) -> void:
    if is_falling:
        # Gravity
        velocity.y += 300 * delta  # gravity

        # Movement
        global_position += velocity * delta

        # Ground collision
        if global_position.y > get_viewport().get_visible_rect().size.y:
            global_position.y = get_viewport().get_visible_rect().size.y
            is_falling = false
            velocity = Vector2.ZERO
            Audio.play_sfx("object_land")
```

---

## Enemy-to-Enemy Knockback Chains

Der **beste Aspekt** von Knockback-fokussiertem Design: **Multiple Enemies pushen sich gegenseitig**.

```gdscript
# In KnockbackSystem.apply_knockback()

func apply_knockback(target: Node2D, knockback_force: Vector2) -> void:
    target.velocity = knockback_force
    target.is_knockback_flying = true

    # Check for collisions with other enemies
    var space_state = target.get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    query.shape = CircleShape2D.new()
    query.shape.radius = 50  # collision detection radius
    query.transform = Transform2D(0, target.global_position + knockback_force.normalized() * 150)

    var results = space_state.intersect_shape(query)

    for result in results:
        var other_enemy = result["collider"]
        if other_enemy != target and other_enemy.is_in_group("enemies"):
            # This enemy is in the path! It gets pushed too
            var secondary_force = knockback_force * 0.7  # 70% transfer
            apply_knockback(other_enemy, secondary_force)
```

### Cascade Effect

```
Player Kick Enemy A (250 px/s) →
  Enemy A flies into Enemy B →
    Enemy B gets pushed (175 px/s = 70% of A's knockback) →
      Enemy B flies into Enemy C →
        Enemy C gets pushed (122 px/s) →
          Multiple Enemies airborne simultaneously
          VISUAL CHAOS = SATISFYING
```

---

## Fast Engagement: 500 px/s Dash

Ein Schlüssel zu "schnellem Engagement" ist **Extreme Dash-Geschwindigkeit**:

```gdscript
# res/combat/dash_system.gd

const DASH_SPEED: float = 500.0  # pixels per second
const DASH_DURATION: float = 0.6  # seconds

func trigger_dash(direction: Vector2) -> void:
    var dash_distance = DASH_SPEED * DASH_DURATION  # 300px

    # Tween für smooth motion
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(
        player,
        "global_position",
        player.global_position + direction * dash_distance,
        DASH_DURATION
    )

    # Während dash, hit alles im Weg
    var enemies_hit: Array = []
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if _is_in_dash_path(enemy):
            enemies_hit.append(enemy)

    # Apply knockback zu allen enemies
    for enemy in enemies_hit:
        var knockback = direction * 200  # Dash knockback
        knockback_system.apply_knockback(enemy, knockback)

    # Audio & visual
    Audio.play_sfx("dash_whoosh")
    _create_dash_trail(direction)
```

**Impact**: Spieler kann in großen Gruppen durchfahren und Gegner überall herumschieben. Das fühlt sich **kraftvoll und befriedigend** an.

---

## Level-Design für Knockback Gameplay

### Environmental Hazards

Knockback ist nur interessant wenn **Umwelt reaktiv ist**:

```gdscript
# res/objects/PitfallTrap.gd

extends Node2D
class_name PitfallTrap

@export var pit_depth: float = 500.0

func _on_enemy_knocked_in(enemy: Node2D) -> void:
    # Enemy falls into pit
    var tween = create_tween()
    tween.tween_property(enemy, "global_position:y", global_position.y + pit_depth, 1.0)
    tween.callback = func(): enemy.take_damage(50)  # Pit damage
    tween.callback = func(): enemy.is_pit_fallen = true  # Mark as incapacitated
```

### Destructible Objects

Knockback kann Umwelt-Objekte zerstören:

```gdscript
# res/objects/DestructibleWall.gd

extends Node2D
class_name DestructibleWall

@export var health: int = 100
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    set_collision_layer_bit(1, true)  # Solid
    set_collision_mask_bit(1, true)

func on_impact(impact_force: float) -> void:
    # Wall takes damage based on impact force
    health -= int(impact_force / 10)

    if health <= 0:
        destroy()
    else:
        # Crack animation
        sprite.modulate = Color.RED
        await get_tree().create_timer(0.1).timeout
        sprite.modulate = Color.WHITE

func destroy() -> void:
    # Crumble animation
    var tween = create_tween()
    tween.tween_property(sprite, "rotation", PI, 0.3)
    tween.tween_property(sprite, "modulate:a", 0.0, 0.3)

    # Debris particles
    var debris = preload("res://Scenes/Effects/WallDebris.tscn").instantiate()
    get_parent().add_child(debris)
    debris.global_position = global_position

    # Remove collision
    queue_free()
```

---

## Feedback Layering

Knockback braucht **massive Feedback** um sich befriedigend zu fühlen:

### Audio Layers

```gdscript
# res/audio/knockback_audio.gd

func play_knockback_feedback(intensity: float) -> void:
    # Layer 1: Impact sound (varies by intensity)
    if intensity < 200:
        Audio.play_sfx("hit_light")
    elif intensity < 400:
        Audio.play_sfx("hit_medium")
    else:
        Audio.play_sfx("hit_heavy")

    # Layer 2: Whoosh (air movement)
    Audio.play_sfx("knockback_whoosh", _get_pitch_from_intensity(intensity))

    # Layer 3: Impact (if wall collision)
    # Handled separately in collision system

    # Layer 4: Enemy reaction sound (optional)
    if enemy_is_stunned:
        Audio.play_sfx("enemy_stun_grunt")
```

### Visual Layers

```gdscript
# Knockback visual feedback

# Layer 1: Sprite shake/blur
sprite.modulate = Color.RED
await get_tree().create_timer(0.05).timeout
sprite.modulate = Color.WHITE

# Layer 2: Trail/motion lines
_create_knockback_trail(velocity)

# Layer 3: Screen shake (camera)
camera.shake(intensity * 0.1, 0.1)

# Layer 4: Particle effects
_create_impact_particles(impact_pos)

# Layer 5: UI feedback
combo_display.pulse()
damage_number.show(final_damage)
```

---

## Integration mit anderen Systemen

### Mit Combo System
Je höher Combo, desto höher Knockback:
```gdscript
var combo_multiplier = 1.0 + (combo_count - 1) * 0.3
var final_knockback = base_knockback * combo_multiplier
```

### Mit Docking System
Auto-Dash hat Knockback-Komponente:
```gdscript
# Docking Push gibt gegner kleine knockback
var dock_push_force = 50.0  # nicht full damage, nur nudge
```

### Mit Rhythm System
Perfect Hits haben höheres Knockback:
```gdscript
var rhythm_multiplier = is_perfect_hit ? 1.5 : 1.0
```

---

## Testing & Validation

### Feel Tests
- [ ] Knockback fühlt sich **kraftvoll** an (nicht schwach)
- [ ] Wall-Collisions sind **befriedigend** (gute Audio/VFX)
- [ ] Enemy-Chains erzeugen **Chaos-Gefühl**
- [ ] Level-Design ist **für Knockback optimiert**

### Mechanical Tests
- [ ] Knockback-Berechnung ist konsistent
- [ ] Chain-Reactions funktionieren (keine Infinite Loops)
- [ ] Objekt-Pushes funktionieren (Physik ist stabil)
- [ ] Knockback-Flying ist visualisiert (Spieler weiß was passiert)

### Balance Tests
- [ ] Ein 3-Hit Combo Kickback pusht mehrere Gegner
- [ ] Gegner können nicht permanent gepusht werden (Escape-Fenster)
- [ ] Knockback ist fair (nicht OP, nicht schwach)
- [ ] Level-Design ist challengend (Knockback ist Skill-basiert)

---

## Progression

### Early Game
- Knockback: 100-200 px/s (Soft)
- Wall-Collisions: Schwach (visuelle Feedback minimal)
- Enemy-Chains: Nicht möglich (nur 1-2 enemies)

### Mid Game
- Knockback: 200-400 px/s (Medium)
- Wall-Collisions: Medium (kleine Cracks)
- Enemy-Chains: 3-4 enemies möglich

### Late Game/Boss
- Knockback: 400-1000 px/s (Heavy)
- Wall-Collisions: Dramatisch (große Cracks, Objects break)
- Enemy-Chains: 5+ enemies in Kaskade
- Environmental Hazards: Gegner können in Pits/Spikes geknocked werden

---

## Fazit

**GGC-Inspiration (Knockback First)** transformiert Combat von "wie viel Schaden?" zu "wie weit fliegt der Gegner?"

Dies ist wichtig weil:
- **Knockback ist sichtbar** (befriedigend)
- **Chain-Reactions sind möglich** (emergentes Gameplay)
- **Umwelt wird interaktiv** (Level-Design ist dynamic)
- **Multiple Enemies = Chaos = Spaß** (nicht boring)

Ein essentieller Design-Prinzip für befriedigende, visuelle Action-Gameplay.
