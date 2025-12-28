class_name RunState
extends State


func enter() -> void:
	super.enter()
	print("Entered Run State")
	
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
	if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
		return states.get("attack")
	return null

func process_physics(delta: float) -> State:
	# Get input direction
	var direction = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)

	if direction != 0:
		# Movement with acceleration envelope
		var target_speed = direction * parent.max_speed

		# Check if turning (changing direction)
		var is_turning = sign(parent.velocity.x) != sign(direction) and parent.velocity.x != 0.0

		if is_turning:
			# Faster direction change with turn_speed
			var turn_accel = (
				parent.deceleration + parent.acceleration
				) * parent.max_speed * parent.turn_speed
			parent.velocity.x = move_toward(parent.velocity.x, target_speed, turn_accel * delta)
		else:
			# Normal acceleration
			parent.velocity.x = move_toward(
				parent.velocity.x, target_speed,
				parent.acceleration * parent.max_speed * delta)

		# Update sprite direction
		parent.sprite.flip_h = direction < 0
	else:
		# No input - apply deceleration
		parent.velocity.x = move_toward(
			parent.velocity.x, 0.0,
			parent.deceleration * parent.max_speed * delta
			)

		# Transition to idle when stopped
		if abs(parent.velocity.x) < 10.0:
			parent.velocity.x = 0
			return states.get("idle")

	parent.move_and_slide()

	# Check if falling off edge
	if !parent.is_on_floor():
		# Start coyote timer when leaving ground
		parent.coyote_timer = parent.coyote_time
		return states.get("fall")

	return null
