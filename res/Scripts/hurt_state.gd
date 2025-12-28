class_name HurtState
extends State

# Knockback properties (Simon's Quest style)
@export var knockback_force: float = 300.0
@export var knockback_duration: float = 0.4
@export var invincibility_duration: float = 1.0

var knockback_timer: float = 0.0
var knockback_direction: float = 1.0


func enter() -> void:
	super.enter()
	print("Entered Hurt State - Knockback!")

	knockback_timer = knockback_duration

	# Get knockback direction (opposite of sprite direction)
	knockback_direction = -1.0 if not parent.sprite.flip_h else 1.0

	# Apply knockback velocity (horizontal + small upward boost)
	parent.velocity.x = knockback_direction * knockback_force
	parent.velocity.y = -200.0

	# Start invincibility frames
	parent.is_invincible = true
	parent.invincibility_timer = invincibility_duration

	# Visual feedback: Start blinking
	if parent.has_node("InvincibilityTimer"):
		parent.get_node("InvincibilityTimer").start(invincibility_duration)

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	# No input during knockback
	return null

func process_physics(delta: float) -> State:
	# Update knockback timer
	knockback_timer -= delta

	# Maintain knockback velocity (no control)
	parent.velocity.x = knockback_direction * knockback_force

	# Apply reduced gravity for floaty knockback feel
	gravity_multiplier = 0.6

	parent.move_and_slide()

	# Check if knockback finished
	if knockback_timer <= 0:
		if parent.is_on_floor():
			return states.get("idle")
		return states.get("fall")

	return null
