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
	# Buffer jump input while falling
	if event.is_action_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	return null

func process_physics(delta: float) -> State:
	# Update jump buffer timer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Determine gravity multiplier based on jump button state
	var gravity_multiplier = 1.0
	if not Input.is_action_pressed("jump"):
		gravity_multiplier = parent.down_gravity_multiplier

	# Apply gravity with multiplier
	parent.velocity.y += gravity * gravity_multiplier * delta

	# Clamp fall speed to prevent falling too fast
	parent.velocity.y = min(parent.velocity.y, max_fall_speed)

	# Handle horizontal movement while falling
	var movement = Input.get_axis("move_left", "move_right") * move_speed
	if movement != 0:
		parent.sprtite.flip_h = movement < 0
	parent.velocity.x = movement
	parent.move_and_slide()

	# Transition to ground states when landing
	if parent.is_on_floor():
		# Check if jump was buffered
		if jump_buffer_timer > 0:
			return states.get("jump")

		if movement != 0:
			return states.get("run")
		return states.get("idle")

	return null
