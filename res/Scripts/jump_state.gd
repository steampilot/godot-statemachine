class_name JumpState
extends State


func enter() -> void:
	super.enter()
	print("Entered Jump State")
	# Berechne jump_force basierend auf gewünschter jump_height
	# Formel: v = sqrt(2 * g * h) aus v² = 2gh
	var jump_force = sqrt(2.0 * gravity * parent.jump_height)
	# Apply an immediate upward force to the player's velocity
	parent.velocity.y = - jump_force

func process_input(event: InputEvent) -> State:
	# Check air dash input (Jump + any direction while airborne)
	if event.is_action_pressed(INPUT_ACTIONS.JUMP):
		var dash_dir = parent.get_dash_direction()
		if dash_dir.length_squared() > 0 and parent.can_air_dash:
			return states.get("dash")
	if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
		return states.get("attack")
	return null

func process_physics(delta: float) -> State:
	# Check if jump button released early -> switch to fall state for faster descent
	if not Input.is_action_pressed(INPUT_ACTIONS.JUMP):
		return states.get("fall")

	# Check if reached peak (velocity becomes zero or positive) -> switch to fall state
	if parent.velocity.y >= 0:
		return states.get("fall")

	# Handle horizontal movement while jumping (with air control)
	var direction = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)
	if direction != 0:
		var target_speed = direction * parent.max_speed
		var air_accel = parent.acceleration * parent.max_speed * parent.air_control
		parent.velocity.x = move_toward(parent.velocity.x, target_speed, air_accel * delta)
		parent.sprite.flip_h = direction < 0
	parent.move_and_slide()

	# Emergency floor check (shouldn't happen during normal jump)
	if parent.is_on_floor():
		if direction != 0:
			return states.get("run")
		return states.get("idle")

	return null
