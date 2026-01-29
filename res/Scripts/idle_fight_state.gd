class_name IdleFightState
extends State

# Fight stance properties
@export var stance_duration: float = 2.0

var stance_timer: float = 0.0
var movement_locked: bool = true


func enter() -> void:
    super.enter()
    print("Entered Idle Fight State")

    # Initialize stance timer
    stance_timer = stance_duration
    movement_locked = true

    # Stop all movement
    parent.velocity.x = 0

func exit() -> void:
    movement_locked = false

func process_input(event: InputEvent) -> State:
    # Track button releases to unlock movement
    if movement_locked:
        if event.is_action_released(INPUT_ACTIONS.MOVE_LEFT):
            movement_locked = false
            print("Movement unlocked (left released)")
        if event.is_action_released(INPUT_ACTIONS.MOVE_RIGHT):
            movement_locked = false
            print("Movement unlocked (right released)")

    # Only allow transitions if movement is unlocked
    if not movement_locked:
        # Check for ladder grabbing (UP or DOWN while on ladder)
        if parent.on_ladder:
            if event.is_action_pressed(
                INPUT_ACTIONS.MOVE_UP) or event.is_action_pressed(
                    INPUT_ACTIONS.MOVE_DOWN):
                return states.get("ladder_grab")

        # Check dash input
        if event.is_action_pressed(INPUT_ACTIONS.JUMP):
            var dash_dir = parent.get_dash_direction()
            if dash_dir.length_squared() > 0:
                return states.get("dash")
            # Normal jump if no dash direction
            if parent.is_on_floor():
                return states.get("jump")

        # Check movement input - only if buttons released first
        if event.is_action_pressed(INPUT_ACTIONS.MOVE_LEFT):
            return states.get("run")
        if event.is_action_pressed(INPUT_ACTIONS.MOVE_RIGHT):
            return states.get("run")

    # Allow attack chains from fight stance
    if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
        return states.get("attack")

    return null

func process_physics(delta: float) -> State:
    # Update stance timer
    stance_timer -= delta

    # Apply deceleration to stop smoothly
    parent.velocity.x = move_toward(
        parent.velocity.x, 0.0,
        parent.deceleration * parent.max_speed * delta
    )

    parent.move_and_slide()

    # Check if falling off edge
    if not parent.is_on_floor():
        return states.get("fall")

    # Timeout - return to normal idle
    if stance_timer <= 0:
        print("Fight stance timeout - returning to idle")
        return states.get("idle")

    return null
