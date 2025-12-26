class_name RunState
extends State


func enter() -> void:
	super.enter()
	print("Entered Run State")

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed(INPUT_ACTIONS.JUMP) and parent.is_on_floor():
		return states.get("jump")
	if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
		return states.get("attack")
	return null

func process_physics(delta: float) -> State:
	# Apply gravity
	parent.velocity.y += gravity * delta

	# Get input direction
	var direction = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)

	if direction != 0:
		# Movement with acceleration envelope
		var target_speed = direction * parent.max_speed

		# Check if turning (changing direction)
		var is_turning = sign(parent.velocity.x) != sign(direction) and parent.velocity.x != 0.0

		if is_turning:
			# Faster direction change with turn_speed
			var turn_accel = (parent.deceleration + parent.acceleration) * parent.turn_speed
			parent.velocity.x = move_toward(parent.velocity.x, target_speed, turn_accel * delta)
		else:
			# Normal acceleration
			parent.velocity.x = move_toward(
				parent.velocity.x, target_speed,
				parent.acceleration * delta)

		# Update sprite direction
		parent.sprite.flip_h = direction < 0
	else:
		# No input - apply deceleration
		parent.velocity.x = move_toward(
			parent.velocity.x, 0.0,
			parent.deceleration * delta
			)

		# Transition to idle when stopped
		if abs(parent.velocity.x) < 10.0:
			parent.velocity.x = 0
			return states.get("idle")

	parent.move_and_slide()

	# Check if falling off edge
	if !parent.is_on_floor():
		return states.get("fall")

	return null
