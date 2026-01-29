class_name DashState
extends State

# Dash properties
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var was_airborne: bool = false


func enter() -> void:
    super.enter()
    print("Entered Dash State")

    dash_timer = dash_duration
    was_airborne = not parent.is_on_floor()

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
