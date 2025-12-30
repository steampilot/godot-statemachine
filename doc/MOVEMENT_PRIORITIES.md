# MOVEMENT PRIORITIES: PHASE-BASIERTE PERFEKTIONIERUNG

## Überblick

**Movement Polish ist Priorität #1 vor Combat**. Ein Spiel mit perfektem Movement und mittelmäßigen Kampf fühlt sich poliert an. Ein Spiel mit mittelmäßigem Movement und perfektem Kampf fühlt sich frustierend an.

Diese Dokumentation definiert die **5-Phasen Strategie** zur Bewegungs-Perfektionierung, mit messbaren Tests für jede Phase.

**Begründung**: Spieler merkt schlechtes Movement sofort (in ersten 10 Sekunden). Schlechten Kampf merkt er später. Bewegung ist das **Foundation** von alles Anderem.

---

## Phase 1: Input Responsiveness (Woche 1-2)

### Ziel
Spieler drückt eine Taste → **unmittelbarer visueller Feedback** (< 50ms).

### Kern-Anforderungen

#### 1. Input Latency
```gdscript
# res/debug/input_latency_monitor.gd
# Monitor actual input latency

extends Node

var input_pressed_time: float = 0.0
var sprite_responded_time: float = 0.0

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("move_right"):
        input_pressed_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
    # Check when sprite actually moves/animates
    if sprite_is_animating():
        sprite_responded_time = Time.get_ticks_msec()
        var latency = sprite_responded_time - input_pressed_time

        # Goal: < 50ms
        if latency > 50:
            print("WARNING: Input latency too high: %dms" % latency)

        input_pressed_time = 0.0
```

**Test-Kriterien:**
- [ ] Input → Sprite Animation: ≤ 50ms
- [ ] Input → Camera Follow: ≤ 100ms
- [ ] Dash Button → Dash Start: ≤ 75ms
- [ ] Jump Button → Jump Start: ≤ 50ms

#### 2. Input Buffering (Optional)
```gdscript
# Buffer inputs for coyote jump, dash buffering, etc.

var input_buffer: Dictionary = {
    "jump": false,
    "dash": false,
    "attack": false
}
var buffer_time: float = 0.05  # 50ms buffer

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        input_buffer["jump"] = true
        await get_tree().create_timer(buffer_time).timeout
        input_buffer["jump"] = false

func _process(_delta: float) -> void:
    if input_buffer["jump"] and is_on_floor():
        perform_jump()
        input_buffer["jump"] = false
```

**Warum wichtig**: Spieler drückt Jump, aber 40ms später ist er am Boden. Input Buffering macht das normal.

### Deliverables
- [ ] Movement System mit < 50ms Input Latency
- [ ] Input Buffering für Jump/Dash
- [ ] Debug-Anzeige für Input-Latenz (entwicklungs-only)

---

## Phase 2: Animation Smoothness (Woche 3-4)

### Ziel
Übergänge zwischen Bewegungs-States sind **smooth und lesbar**.

### Kern-Anforderungen

#### 1. State Transitions
```gdscript
# res/entities/player_animator.gd
# Control smooth state transitions

extends Node

enum State { IDLE, RUN, JUMP, FALL, DASH, LAND }
var current_state: State = State.IDLE
var previous_state: State = State.IDLE

func transition_to(new_state: State) -> void:
    previous_state = current_state
    current_state = new_state

    # Play transition animation based on previous → current
    var animation_key = "%s_to_%s" % [State.keys()[previous_state], State.keys()[new_state]]

    if animation_player.has_animation(animation_key):
        animation_player.play(animation_key)
    else:
        # Fallback: direct transition
        animation_player.play(State.keys()[new_state])

func _process(delta: float) -> void:
    # Determine next state
    var next_state = determine_state()

    if next_state != current_state:
        transition_to(next_state)

func determine_state() -> State:
    if velocity.y < 0:
        return State.JUMP
    elif velocity.y > 0:
        if is_on_floor():
            return State.LAND
        else:
            return State.FALL
    elif velocity.x != 0:
        return State.RUN
    else:
        return State.IDLE
```

**Test-Kriterien:**
- [ ] Idle → Run: Smooth (keine Zuckungen)
- [ ] Run → Jump: Animation startet sofort
- [ ] Jump → Fall: Übergang ist natürlich (nicht abrupt)
- [ ] Fall → Land: Landing-Animation spiels (Dust, Squash)
- [ ] Land → Idle: Kein Flick, smooth deceleration

#### 2. Blend Spaces für Übergänge
```gdscript
# Nutze AnimationBlendSpace für smooth Übergänge

# In AnimationPlayer:
# - Blend Space: "Run" (Speed 0.0 → 1.0)
#   - 0.0: Idle with slight lean forward
#   - 0.5: Run mid-speed
#   - 1.0: Run at full speed
#
# Effekt: Speed ändert Animation smooth (nicht Snap)

func _process(delta: float) -> void:
    var speed = velocity.x / max_speed
    speed = clamp(speed, 0.0, 1.0)

    animation_player.playback_speed = speed
    # Or use blend_space parameters
    animation_state.set_blend_position("speed", speed)
```

#### 3. Dash Animation Chain
```gdscript
# Dash sollte folgende Sequenz haben:
# 1. Windup (0.1s) - Spieler nimmt Anlauf
# 2. Dash (0.4s) - Schnelle Bewegung
# 3. Recovery (0.2s) - Spieler "bremst"

func trigger_dash(direction: Vector2) -> void:
    var tween = create_tween()
    tween.set_parallel(false)  # Sequential

    # Windup
    tween.tween_callback(animation_player.play.bind("dash_windup"))
    tween.tween_interval(0.1)

    # Dash
    tween.tween_callback(animation_player.play.bind("dash_move"))
    tween.tween_property(self, "global_position",
        global_position + direction * 300, 0.4)

    # Recovery
    tween.tween_callback(animation_player.play.bind("dash_recover"))
    tween.tween_interval(0.2)

    # Back to normal
    tween.tween_callback(func(): transition_to(State.IDLE))
```

### Deliverables
- [ ] Alle Bewegungs-States haben Animationen
- [ ] Alle Übergänge sind smooth (keine Snaps)
- [ ] Dash/Jump/Fall haben 3-Phase Animations
- [ ] Landing-Feedback (Dust particles, Sound)

---

## Phase 3: Physics Feel (Woche 5-6)

### Ziel
Bewegungs-**Physik fühlt sich right an**: nicht zu schwerfällig, nicht zu floaty.

### Kern-Anforderungen

#### 1. Acceleration & Deceleration

```gdscript
# res/entities/player_physics.gd

@export var max_speed: float = 200.0
@export var acceleration: float = 1200.0  # pixels/s²
@export var friction: float = 800.0      # deceleration

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
    # Horizontal movement
    var input_direction = get_input_direction()

    if input_direction != 0:
        # Accelerate towards max speed
        velocity.x += input_direction * acceleration * delta
        velocity.x = clamp(velocity.x, -max_speed, max_speed)
    else:
        # Decelerate (friction)
        velocity.x = move_toward(velocity.x, 0, friction * delta)

    # Vertical (gravity)
    velocity.y += gravity * delta

    # Movement
    velocity = move_and_slide(velocity)

func get_input_direction() -> int:
    var input = 0
    if Input.is_action_pressed("move_right"):
        input += 1
    if Input.is_action_pressed("move_left"):
        input -= 1
    return input
```

**Tuning-Werte** (experimentieren):
- **Acceleration**: 1000-1500 (schneller = twitchier)
- **Friction**: 600-1000 (höher = abrupter Stop)
- **Gravity**: 500-800 (höher = schneller Fall)
- **Jump Force**: 300-400 pixels/s

**Test**: Character sollte sich "snappy" anfühlen, aber nicht unberechenbar.

#### 2. Jump Mechanics

```gdscript
# Jump sollte haben:
# - Coyote Jump (können für 100ms nach Kante springen)
# - Variable Jump Height (länger halten = höher springen)
# - Wall Jump (optional)

const COYOTE_TIME: float = 0.1  # seconds
var coyote_timer: float = 0.0
var was_on_floor: bool = false

func _process(delta: float) -> void:
    # Coyote time
    if is_on_floor():
        coyote_timer = COYOTE_TIME
    else:
        coyote_timer -= delta

func jump() -> void:
    # Can jump if on floor OR coyote time active
    if is_on_floor() or coyote_timer > 0:
        velocity.y = -jump_force
        coyote_timer = 0  # Consume coyote

func _process_variable_jump(delta: float) -> void:
    # If releasing jump, reduce upward velocity
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= 0.5  # Jump height reduction
```

**Warum wichtig**: Platformer-Handling ist **lebenswichtig**. Celeste, Hollow Knight, alle großen Platformer haben exzellente Jump-Mechanik.

#### 3. Dash Physics

```gdscript
# Dash sollte sein:
# - Fast (500 px/s)
# - Controllable (direction bestimmbar)
# - Refreshable (kann wieder dashen nach 0.5s oder bei Landing)

@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.4
var dashes_remaining: int = 1
var max_dashes: int = 1
var dash_on_cooldown: bool = false

func trigger_dash(direction: Vector2) -> void:
    if dashes_remaining <= 0 or dash_on_cooldown:
        return

    dashes_remaining -= 1
    dash_on_cooldown = true

    # Dash movement
    var dash_distance = dash_speed * dash_duration
    var tween = create_tween()
    tween.tween_property(self, "global_position",
        global_position + direction.normalized() * dash_distance,
        dash_duration)

    # After dash, cooldown
    await get_tree().create_timer(0.3).timeout
    dash_on_cooldown = false

func _on_landed() -> void:
    # Refresh dash on landing
    dashes_remaining = max_dashes
```

### Deliverables
- [ ] Acceleration/Friction ist tuned und "feels right"
- [ ] Jump mechanics (Coyote, Variable Height)
- [ ] Dash mechanics (Fast, Directional, Refreshable)
- [ ] Gravity tuned (nicht too heavy, not too floaty)

---

## Phase 4: Feedback & Polish (Woche 7-8)

### Ziel
Movement hat **umfangreiches Feedback**: Audio, Particles, Screen Effects.

### Kern-Anforderungen

#### 1. Footstep Audio
```gdscript
# res/audio/footstep_system.gd

func _process(delta: float) -> void:
    if is_on_floor() and velocity.x != 0:
        _play_footstep()

var last_footstep_time: float = 0.0
const FOOTSTEP_INTERVAL: float = 0.3  # seconds between steps

func _play_footstep() -> void:
    var current_time = Time.get_ticks_msec() / 1000.0

    if current_time - last_footstep_time < FOOTSTEP_INTERVAL:
        return

    # Pitch varies by speed
    var speed_ratio = abs(velocity.x) / max_speed
    var pitch = 0.9 + speed_ratio * 0.2  # 0.9 - 1.1

    Audio.play_sfx("footstep", 1.0, pitch)
    last_footstep_time = current_time
```

#### 2. Jump/Land Feedback
```gdscript
# Jump sound & visual

func jump() -> void:
    if can_jump():
        velocity.y = -jump_force
        Audio.play_sfx("jump")
        _create_jump_particles()

func _on_landed() -> void:
    var impact_force = abs(velocity.y)

    # Sound (pitch varies by fall distance)
    var pitch = 1.0 + (impact_force / 500.0)
    Audio.play_sfx("land", 1.0, pitch)

    # Particles
    _create_landing_dust()

    # Screen feedback
    if impact_force > 300:  # Heavy landing
        camera.shake(0.1, 0.2)
        screen_overlay.flash(Color.WHITE, 0.1)
```

#### 3. Dash Feedback
```gdscript
# Dash sollte haben: Sound, Trail, Screen Flash

func trigger_dash(direction: Vector2) -> void:
    Audio.play_sfx("dash_whoosh")
    _create_dash_trail(direction)

    var tween = create_tween()
    tween.tween_property(self, "global_position", ...)

    # Mid-dash screen feedback
    camera.shake(0.05, 0.1)
```

#### 4. Particle Effects
```gdscript
# Land particles, dash trail, jump burst

func _create_landing_dust() -> void:
    var particles = preload("res://Scenes/Effects/LandDust.tscn").instantiate()
    get_parent().add_child(particles)
    particles.global_position = global_position
    particles.emitting = true

func _create_dash_trail(direction: Vector2) -> void:
    var trail = preload("res://Scenes/Effects/DashTrail.tscn").instantiate()
    get_parent().add_child(trail)
    trail.direction = direction
    trail.start()
```

### Deliverables
- [ ] Footstep Audio (variiert bei Speed)
- [ ] Jump/Land Sounds & Particles
- [ ] Dash Sound & Visual Trail
- [ ] Camera Shake auf Impact
- [ ] Screen Flashes auf große Events

---

## Phase 5: Edge Cases & Refinement (Woche 9-12)

### Ziel
Alle edge cases sind gelöst, Movement ist **absolut poliert**.

### Kern-Anforderungen

#### 1. Slope Handling
```gdscript
# Spieler sollte smoothly über slopes gehen, nicht stecken bleiben

func _process(delta: float) -> void:
    # Auto-align to slope
    if is_on_floor():
        var floor_normal = get_floor_normal()
        var slope_angle = floor_normal.angle_to(Vector2.UP)

        # Adjust velocity to follow slope
        if abs(slope_angle) < 1.2:  # Max 70 degrees
            velocity = velocity.rotated(slope_angle)
```

#### 2. Corner Correction
```gdscript
# Wenn Spieler an einer Ecke stuck ist, schiebe ihn sanft hoch

func _process(delta: float) -> void:
    var collision = move_and_collide(velocity * delta)

    if collision:
        # Try pushing player up slightly
        var push_up = Vector2(0, -5)
        move_and_collide(push_up)

        # Then try original movement
        collision = move_and_collide(velocity * delta)
```

#### 3. Ladder Handling
```gdscript
# Auf Leitern: kann auf/ab gehen, Jump verlässt Leiter

var on_ladder: bool = false

func _process(delta: float) -> void:
    if on_ladder:
        var input_direction = get_input_direction()
        velocity.y = input_direction * ladder_speed

        # Jump leaves ladder
        if Input.is_action_pressed("jump"):
            on_ladder = false
            velocity.y = -jump_force
```

#### 4. Wall Sliding (Optional)
```gdscript
# Wenn gegen Wand und fallend: slide down langsamer

var on_wall: bool = false
const WALL_SLIDE_SPEED: float = 50.0

func _process(delta: float) -> void:
    if is_on_wall() and velocity.y > 0:
        on_wall = true
        velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
    else:
        on_wall = false
```

#### 5. Input Buffering Refinement
```gdscript
# Verfeinerte Input-Buffering für Combos

var jump_buffered: bool = false
var dash_buffered: bool = false
var attack_buffered: bool = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        jump_buffered = true
        await get_tree().create_timer(0.05).timeout
        jump_buffered = false

    if event.is_action_pressed("dash"):
        dash_buffered = true
        await get_tree().create_timer(0.05).timeout
        dash_buffered = false

func _process(delta: float) -> void:
    # Check buffers and execute if conditions met
    if jump_buffered and can_jump():
        perform_jump()
        jump_buffered = false

    if dash_buffered and can_dash():
        perform_dash()
        dash_buffered = false
```

### Deliverables
- [ ] Slope walking ist smooth
- [ ] Ecken-Handling ist robust
- [ ] Leitern funktionieren
- [ ] Wall Sliding (optional) arbeitet
- [ ] Input Buffering ist perfekt

---

## Testing Framework

```gdscript
# res/tests/movement_tests.gd
# GUT-basierte Tests für Movement

extends GutTest

func test_input_responsiveness() -> void:
    # Simulate input
    simulate_input("move_right")

    # Check response time
    var start = Time.get_ticks_msec()
    await player.animation_player.animation_finished
    var latency = Time.get_ticks_msec() - start

    assert_less(latency, 50, "Input latency should be < 50ms")

func test_jump_velocity() -> void:
    # Jump should set velocity.y to negative value
    player.trigger_jump()
    assert_less(player.velocity.y, 0)

func test_dash_distance() -> void:
    # Dash should move 300px
    var start_pos = player.global_position
    player.trigger_dash(Vector2.RIGHT)
    await get_tree().create_timer(0.5).timeout
    var distance = player.global_position.distance_to(start_pos)
    assert_between(distance, 290, 310)  # ~300px

func test_coyote_jump() -> void:
    # Should be able to jump 100ms after leaving floor
    player.position.y = 0  # on ground
    player.trigger_jump()

    # Leave ground
    player.position.y = 50
    await get_tree().create_timer(0.05).timeout

    # Should still be able to jump
    assert_true(player.can_jump(), "Coyote jump should work")
```

---

## Messung & Metriken

### Phase 1: Input Responsiveness
- **Metric**: Average input-to-response latency
- **Goal**: < 50ms
- **Measure**: `Input Latency Monitor` at runtime

### Phase 2: Animation Smoothness
- **Metric**: Transitions per frame (should be 0-1, not jumpy)
- **Goal**: Smooth (visual inspection)
- **Measure**: Manual playtesting + Video Analysis

### Phase 3: Physics Feel
- **Metric**: Jump Height, Acceleration Curves, Gravity
- **Goal**: Feels similar to Celeste/Hollow Knight
- **Measure**: Physics Tuning Pass + Player Feedback

### Phase 4: Feedback
- **Metric**: Audio/Visual/Haptic events per action
- **Goal**: Each action has ≥3 feedback channels
- **Measure**: Checklist + Visual Inspection

### Phase 5: Edge Cases
- **Metric**: Bug count related to Movement
- **Goal**: Zero critical bugs
- **Measure**: QA Testing + Player Feedback

---

## Roadmap Integration

```
ARTEMIS Movement Phase:
Week 1-2: Input Responsiveness (Phase 1)
Week 3-4: Animation (Phase 2)
Week 5-6: Physics (Phase 3)
Week 7-8: Polish (Phase 4)
Week 9-12: Edge Cases (Phase 5)

Nach Phase 5 → Combat System kann beginnen
(Combat wird auf "polished movement" aufbauen)
```

---

## Best Practices Checklist

- [ ] **Playtesten regelmäßig**: Mindestens wöchentlich
- [ ] **Vergleiche mit Referenzen**: Celeste, Hollow Knight, Ghouls N Ghosts
- [ ] **Tuning Document**: Alle Werte dokumentieren, experimentiert haben
- [ ] **Debug Visuals**: Velocity Vectors, Hitboxes sichtbar
- [ ] **Controller + Keyboard**: Beide Input-Methoden testen
- [ ] **Verschiedene Screen-Größen**: Responsiveness bleibt konsistent

---

## Fazit

**Movement ist Foundation.** Die 5 Phasen stellen sicher, dass:
1. Input wird erkannt (Responsiveness)
2. Aktionen sehen gut aus (Animation)
3. Physik fühlt sich right an (Feel)
4. Alles hat Feedback (Polish)
5. Edge Cases sind gelöst (Robustheit)

Eine polierte Bewegungs-Engine macht alles Andere einfacher. Ein schlechtes Movement verdirbt das gesamte Spiel, unabhängig von Kampf oder Story.

**Investition in Movement = Investition in Game-Feel.**
