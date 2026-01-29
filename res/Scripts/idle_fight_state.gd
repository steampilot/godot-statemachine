class_name IdleFightState
extends State

# Fight stance properties
@export var movement_activation_delay: float = 0.25
@export var stance_duration: float = 2.0

# Internal sub-states (LSL style)
enum InternalState {ATTACK_ONLY, MOVEMENT_ALLOWED}
var internal_state: InternalState = InternalState.ATTACK_ONLY

var timer_t1: float = 0.0
var timer_t2: float = 0.0


func enter() -> void:
    super.enter()
    print("Entered Idle Fight State")

    # State entry: Initialize timers and sub-state
    internal_state = InternalState.ATTACK_ONLY
    timer_t1 = movement_activation_delay
    timer_t2 = stance_duration

    # Stop all movement
    parent.velocity.x = 0

func exit() -> void:
    pass

func process_input(event: InputEvent) -> State:
    # Check for ladder grabbing (always allowed)
    if parent.on_ladder:
        if event.is_action_pressed(
            INPUT_ACTIONS.MOVE_UP) or event.is_action_pressed(
                INPUT_ACTIONS.MOVE_DOWN):
            return states.get("ladder_grab")

    # Attack button listener (allowed in ALL sub-states)
    if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
        return states.get("attack")

    # Movement/Jump listeners - only in MOVEMENT_ALLOWED state
    if internal_state == InternalState.MOVEMENT_ALLOWED:
        # Jump input
        if event.is_action_pressed(INPUT_ACTIONS.JUMP):
            var dash_dir = parent.get_dash_direction()
            if dash_dir.length_squared() > 0:
                return states.get("dash")
            if parent.is_on_floor():
                return states.get("jump")

        # Movement input
        if event.is_action_pressed(INPUT_ACTIONS.MOVE_LEFT):
            return states.get("run")
        if event.is_action_pressed(INPUT_ACTIONS.MOVE_RIGHT):
            return states.get("run")

    return null

func process_physics(delta: float) -> State:
    # Update timers
    timer_t1 -= delta
    timer_t2 -= delta

    # Timer T1 listener: Transition to MOVEMENT_ALLOWED sub-state
    if internal_state == InternalState.ATTACK_ONLY and timer_t1 <= 0:
        print("T1 expired - transitioning to MOVEMENT_ALLOWED sub-state")
        internal_state = InternalState.MOVEMENT_ALLOWED

        # Check if movement/jump buttons are ALREADY held down
        if Input.is_action_pressed(INPUT_ACTIONS.JUMP):
            print("Jump button was held - transitioning to jump/dash")
            var dash_dir = parent.get_dash_direction()
            if dash_dir.length_squared() > 0:
                return states.get("dash")
            if parent.is_on_floor():
                return states.get("jump")

        if Input.is_action_pressed(INPUT_ACTIONS.MOVE_LEFT):
            print("Left button was held - transitioning to run")
            return states.get("run")

        if Input.is_action_pressed(INPUT_ACTIONS.MOVE_RIGHT):
            print("Right button was held - transitioning to run")
            return states.get("run")

    # Timer T2 listener: Return to idle state
    if timer_t2 <= 0:
        print("T2 expired - returning to idle")
        return states.get("idle")

    # Apply deceleration to stop smoothly
    parent.velocity.x = move_toward(
        parent.velocity.x, 0.0,
        parent.deceleration * parent.max_speed * delta
    )

    parent.move_and_slide()

    # Check if falling off edge
    if not parent.is_on_floor():
        return states.get("fall")

    return null
