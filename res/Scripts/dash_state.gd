class_name DashState
extends State

# Dash properties
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2

# Ghost trail properties
@export var ghost_spawn_interval: float = 0.03
@export var ghost_enabled: bool = true

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var was_airborne: bool = false
var ghost_timer: float = 0.0

# Ghost sprite scene
const GHOST_SCENE = preload("res://Scenes/ghost_sprite.tscn")


func enter() -> void:
    super.enter()
    print("Entered Dash State")

    dash_timer = dash_duration
    ghost_timer = 0.0
    was_airborne = not parent.is_on_floor()

    # Spawn initial ghost at starting position
    if ghost_enabled:
        _spawn_ghost()

    # Get 8-directional dash direction from Player
    dash_direction = parent.get_dash_direction()

    # If no valid direction, default to sprite direction
    if dash_direction.length_squared() == 0:
        dash_direction.x = 1.0 if not parent.sprite.flip_h else -1.0
        dash_direction = dash_direction.normalized()

    # Consume air dash if airborne
    if was_airborne:
        parent.can_air_dash = false

    # Set dash velocity in both directions
    parent.velocity = dash_direction * dash_speed

    # Enable floor snap for ground dashes to stick to slopes
    if not was_airborne:
        parent.floor_stop_on_slope = false
        parent.floor_constant_speed = true

    print("Dash direction: %s (airborne: %s)" % [dash_direction, was_airborne])

func exit() -> void:
    # Reset slope behavior
    parent.floor_stop_on_slope = true
    parent.floor_constant_speed = false

func process_input(_event: InputEvent) -> State:
    return null

func process_physics(delta: float) -> State:
    # Update dash timer
    dash_timer -= delta

    # Spawn ghost trail during dash
    if ghost_enabled:
        ghost_timer -= delta
        if ghost_timer <= 0:
            _spawn_ghost()
            ghost_timer = ghost_spawn_interval

    # Maintain dash velocity (no friction during dash)
    parent.velocity = dash_direction * dash_speed

    # Ground dash: Apply minimal gravity to stick to slopes
    if not was_airborne:
        gravity_multiplier = 0.1
    # Air dash: Ignore gravity completely
    else:
        gravity_multiplier = 0.0

    parent.move_and_slide()

    # Check if dash finished
    if dash_timer <= 0:
        # Transition based on state
        if parent.is_on_floor():
            var direction = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)
            if direction != 0:
                return states.get("run")
            return states.get("idle")
        return states.get("fall")

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

    # Dash ghosts: cyan/white tint for speed effect
    ghost.modulate = Color(0.7, 1.0, 1.0, 0.6)
