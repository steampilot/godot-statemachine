class_name IdleState
extends State

func enter() -> void:
	super.enter()
	print("Entered Idle State")
	parent.velocity.x = 0
	parent.velocity.y = 0

	# Reset air dash when landing
	parent.can_air_dash = true

func process_input(event: InputEvent) -> State:
	# Check dash input (Jump + any direction on D-Pad)
	if event.is_action_pressed(INPUT_ACTIONS.JUMP):
		var dash_dir = parent.get_dash_direction()
		if dash_dir.length_squared() > 0:
			return states.get("dash")
		# Normal jump if no dash direction
		if parent.is_on_floor():
			return states.get("jump")
	if event.is_action_pressed(
		INPUT_ACTIONS.MOVE_LEFT) or event.is_action_pressed(INPUT_ACTIONS.MOVE_RIGHT):
		return states.get("run")
	if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
		return states.get("attack")
	return null


func process_physics(_delta: float) -> State:
	# Check for held movement input (continuous check)
	var direction = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)
	if direction != 0:
		return states.get("run")

	parent.move_and_slide()

	if !parent.is_on_floor():
		return states.get("fall")
	return null
