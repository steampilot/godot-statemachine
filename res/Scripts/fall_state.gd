class_name FallState
extends State

# Maximum fall speed to prevent excessive velocity
@export var max_fall_speed: float = 1000.0

# Jump buffer time - how long to remember jump input before landing
@export var jump_buffer_time: float = 0.15

# Internal timer for jump buffering
var jump_buffer_timer: float = 0.0


func enter() -> void:
    super.enter()
    print("Entered Fall State")
    # Reset jump buffer when entering fall state
    jump_buffer_timer = 0.0

func process_input(event: InputEvent) -> State:
    # Check air dash input (Jump + any direction while falling)
    if event.is_action_pressed(INPUT_ACTIONS.JUMP):
        var dash_dir = parent.get_dash_direction()
        if dash_dir.length_squared() > 0 and parent.can_air_dash:
            return states.get("dash")
        # Normal jump buffer and coyote time
        jump_buffer_timer = jump_buffer_time
        if parent.coyote_timer > 0:
            return states.get("jump")

    # Attack input
    if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
        return states.get("attack")
    return null

func process_physics(delta: float) -> State:
    # Update jump buffer timer
    if jump_buffer_timer > 0:
        jump_buffer_timer -= delta

    # Update coyote timer
    if parent.coyote_timer > 0:
        parent.coyote_timer -= delta

    # Set gravity multiplier based on jump button state (Celeste-style)
    # Button held = normal fall, button released = faster fall for precise control
    if Input.is_action_pressed(INPUT_ACTIONS.JUMP):
        gravity_multiplier = 1.0
    else:
        gravity_multiplier = parent.jump_release_gravity_multiplier

    # Clamp fall speed to prevent falling too fast
    parent.velocity.y = min(parent.velocity.y, max_fall_speed)

    # Handle horizontal movement while falling (with air control)
    var direction = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)
    if direction != 0:
        var target_speed = direction * parent.max_speed
        var air_accel = parent.acceleration * parent.max_speed * parent.air_control
        parent.velocity.x = move_toward(parent.velocity.x, target_speed, air_accel * delta)
        parent.sprite.flip_h = direction < 0
    parent.move_and_slide()

    # Transition to ground states when landing
    if parent.is_on_floor():
        # Check if jump was buffered
        if jump_buffer_timer > 0:
            return states.get("jump")

        if direction != 0:
            return states.get("run")
        return states.get("idle")

    return null
