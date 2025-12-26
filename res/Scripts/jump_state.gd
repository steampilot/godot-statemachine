class_name JumpState
extends State

# Positive value to apply upward force when jumping
@export var jump_force: float = 600.0


func enter() -> void:
	super.enter()
	print("Entered Jump State")
	# Apply an immediate upward force to the player's velocity
	parent.velocity.y = - jump_force

func process_input(_event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	# Check if jump button released early -> switch to fall state for faster descent
	if not Input.is_action_pressed("jump"):
		return states.get("fall")

	# Apply gravity over time (normal gravity while button held)
	parent.velocity.y += gravity * delta

	# Check if reached peak (velocity becomes zero or positive) -> switch to fall state
	if parent.velocity.y >= 0:
		return states.get("fall")

	# Handle horizontal movement while jumping
	var movement = Input.get_axis("move_left", "move_right") * move_speed
	if movement != 0:
		parent.sprtite.flip_h = movement < 0
	parent.velocity.x = movement
	parent.move_and_slide()

	# Emergency floor check (shouldn't happen during normal jump)
	if parent.is_on_floor():
		if movement != 0:
			return states.get("run")
		return states.get("idle")

	return null