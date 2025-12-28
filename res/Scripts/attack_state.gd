class_name AttackState
extends State

# Track if attack animation has finished
var attack_finished: bool = false


func enter() -> void:
	super.enter()
	print("Entered Attack State")
	attack_finished = false

	# Stop horizontal movement during attack
	parent.velocity.x = 0

	# Connect to animation finished signal
	if parent.sprite and not parent.sprite.animation_finished.is_connected(
		_on_attack_animation_finished
		):
		parent.sprite.animation_finished.connect(_on_attack_animation_finished)

	# Enable sword hitbox
	var sword = parent.get_node_or_null("Sword")
	if sword:
		sword.monitoring = true

func exit() -> void:
	# Disable sword hitbox when leaving attack state
	var sword = parent.get_node_or_null("Sword")
	if sword:
		sword.monitoring = false

	# Disconnect signal
	if parent.sprite and \
			parent.sprite.animation_finished.is_connected(_on_attack_animation_finished):
		parent.sprite.animation_finished.disconnect(_on_attack_animation_finished)

func process_input(_event: InputEvent) -> State:
	# No state changes during attack animation
	return null

func process_physics(_delta: float) -> State:
	parent.move_and_slide()

	# Wait for animation to finish
	if attack_finished:
		# Always transition to idle on ground (never run) for stronger feeling
		if parent.is_on_floor():
			return states.get("idle")
		# In air - transition to fall state
		return states.get("fall")

	# Check if fell off edge during attack
	if !parent.is_on_floor() and !attack_finished:
		# Allow falling during attack but stay in attack state until animation finishes
		pass
	return null

func _on_attack_animation_finished() -> void:
	# Only trigger if current animation matches our animation_name
	if parent.sprite and parent.sprite.animation == animation_name:
		attack_finished = true
