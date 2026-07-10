class_name RunSlideState
extends State

# Slide properties
@export var slide_speed: float = 300.0
@export var slide_max_distance: float = 200.0
@export var slide_duration: float = 0.5
# Minimum distance before checking for obstacles (prevents instant wall collision)
@export var min_slide_distance: float = 20.0

# Ghost trail properties
@export var ghost_spawn_interval: float = 0.05
@export var ghost_enabled: bool = true

var slide_timer: float = 0.0
var slide_direction: float = 1.0
var slide_start_position: Vector2 = Vector2.ZERO
var slide_distance_traveled: float = 0.0
var hit_obstacle: bool = false
var ghost_timer: float = 0.0

# Ghost sprite scene
const GHOST_SCENE = preload("res://Scenes/ghost_sprite.tscn")


func enter() -> void:
    super.enter()
    print("Entered Run Slide State")

    # Initialize slide parameters
    slide_timer = slide_duration
    slide_distance_traveled = 0.0
    hit_obstacle = false
    ghost_timer = 0.0
    slide_start_position = parent.global_position

    # Get slide direction from sprite facing
    slide_direction = 1.0 if not parent.sprite.flip_h else -1.0

    # Spawn initial ghost at starting position
    if ghost_enabled:
        _spawn_ghost()

    # Configure SlideSensor raycast
    if parent.slide_sensor:
        parent.slide_sensor.target_position.x = slide_max_distance * slide_direction
        parent.slide_sensor.enabled = true
        # Don't force update immediately - wait for movement first

    # Set initial velocity
    parent.velocity.x = slide_speed * slide_direction
    parent.velocity.y = 0.0

    # Enable floor snap to stick to slopes
    parent.floor_stop_on_slope = false
    parent.floor_constant_speed = true

    print("Slide direction: %s, max distance: %s" % [slide_direction, slide_max_distance])

func exit() -> void:
    # Reset floor behavior
    parent.floor_stop_on_slope = true
    parent.floor_constant_speed = false

    # Disable SlideSensor
    if parent.slide_sensor:
        parent.slide_sensor.enabled = false

func process_input(_event: InputEvent) -> State:
    return null

func process_physics(delta: float) -> State:
    # Update slide timer
    slide_timer -= delta

    # Calculate distance traveled
    slide_distance_traveled = abs(parent.global_position.x - slide_start_position.x)

    # Spawn ghost trail during slide
    if ghost_enabled:
        ghost_timer -= delta
        if ghost_timer <= 0:
            _spawn_ghost()
            ghost_timer = ghost_spawn_interval

    # Check for obstacles with SlideSensor (only after minimum distance)
    if slide_distance_traveled >= min_slide_distance:
        if parent.slide_sensor and parent.slide_sensor.is_colliding():
            hit_obstacle = true
            print("Slide hit obstacle: %s" % parent.slide_sensor.get_collider().name)

    # Maintain slide velocity
    parent.velocity.x = slide_speed * slide_direction

    # Apply minimal gravity to stick to slopes
    gravity_multiplier = 0.1

    parent.move_and_slide()

    # Check exit conditions
    var should_exit = false
    var exit_reason = ""

    # 1. Hit obstacle (wall or enemy)
    if hit_obstacle:
        should_exit = true
        exit_reason = "hit obstacle"

    # 2. Reached max distance
    if slide_distance_traveled >= slide_max_distance:
        should_exit = true
        exit_reason = "max distance reached"

    # 3. Timer expired
    if slide_timer <= 0:
        should_exit = true
        exit_reason = "timer expired"

    # 4. Fell off edge
    if not parent.is_on_floor():
        should_exit = true
        exit_reason = "fell off edge"
        print("Slide ended: %s" % exit_reason)
        return states.get("fall")

    # Exit slide if any condition met
    if should_exit:
        print("Slide ended: %s (distance: %.1f)" % [exit_reason, slide_distance_traveled])

        # Always transition to fight stance after slide
        return states.get("idle_fight")

    return null

# Spawn a ghost sprite at current player position
func _spawn_ghost() -> void:
    if not parent or not parent.sprite:
        return

    var ghost = GHOST_SCENE.instantiate() as Sprite2D
    if not ghost:
        return

    # Get the current scene root to add ghost as sibling
    var scene_root = parent.get_tree().current_scene
    if scene_root:
        scene_root.add_child(ghost)

    # Copy sprite properties
    ghost.global_position = parent.sprite.global_position
    ghost.texture = parent.sprite.sprite_frames.get_frame_texture(
        parent.sprite.animation,
        parent.sprite.frame
    )
    ghost.flip_h = parent.sprite.flip_h
    ghost.offset = parent.sprite.offset

    # Optional: Tint ghost with a color
    ghost.modulate = Color(0.8, 0.8, 1.0, 0.5)
