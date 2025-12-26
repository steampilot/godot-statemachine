class_name IdleState
extends State

func enter() -> void:
	super.enter()
	print("Entered Idle State")
	parent.velocity.y = 0

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed(INPUT_ACTIONS.JUMP) and parent.is_on_floor():
		return states.get("jump")
	if event.is_action_pressed(
		INPUT_ACTIONS.MOVE_LEFT) or event.is_action_pressed(INPUT_ACTIONS.MOVE_RIGHT):
		return states.get("run")
	if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
		return states.get("attack")
	return null


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()

	if !parent.is_on_floor():
		return states.get("fall")
	return null
