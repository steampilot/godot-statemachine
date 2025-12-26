class_name IdleState
extends State

func enter() -> void:
	super.enter()
	print("Entered Idle State")
	parent.velocity.y = 0

func process_input(event: InputEvent) -> State:
	if event.is_action_just_pressed("jump") and parent.is_on_floor():
		return states.get("jump")
	if event.is_action_just_pressed("move_left") or event.is_action_just_pressed("move_right"):
		return states.get("run")
	if event.is_action_just_pressed("attack"):
		return states.get("attack")
	return null


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()

	if !parent.is_on_floor():
		return states.get("fall")
	return null
