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

func process_physics(delta: float) -> State:
	# Apply gravity
	parent.velocity.y += gravity * delta
	parent.move_and_slide()

	# Wait for animation to finish
	if attack_finished:
		# Check if on floor to determine next state
		if parent.is_on_floor():
			# Check if player is moving
			var direction = Input.get_axis("move_left", "move_right")
			if direction != 0:
				return states.get("run")
			return states.get("idle")
			# In air - transition to fall state
		return states.get("fall")

	# Check if fell off edge during attack
	if !parent.is_on_floor() and !attack_finished:
		# Allow falling during attack but stay in attack state until animation finishes
		pass
	return null

func _on_attack_animation_finished() -> void:
	# Only trigger if current animation is "attack"
	if parent.sprite and parent.sprite.animation == "attack":
		attack_finished = true
