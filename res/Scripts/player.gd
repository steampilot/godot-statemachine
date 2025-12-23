extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -200.0

# Variable Jump - Wähle eine Variante aus:
# VARIANTE 1: Fall Multiplier (wie Unity Code)
const FALL_MULTIPLIER = 2.5 # Fällt schneller
const LOW_JUMP_MULTIPLIER = 2.0 # Kurzer Jump, wenn Button losgelassen

# VARIANTE 2: Jump Timer (wie Screenshot)
const JUMP_HOLD_TIME = 0.3 # Maximale Zeit, die man Jump halten kann

# Coyote Time - Jump nach Verlassen der Kante
const COYOTE_TIME = 0.15 # Zeit in Sekunden nach Verlassen der Kante

var jump_timer = 0.0
var is_jumping = false
var coyote_timer = 0.0


func _physics_process(delta: float) -> void:
	# VARIANTE 1: Fall & Low Jump Multiplier
	# Kommentiere diese aus, wenn du Variante 2 benutzen willst
	# apply_variable_jump_gravity_v1(delta)
	# VARIANTE 2: Jump Timer Approach
	# Entkommentiere diese, wenn du Variante 2 benutzen willst
	apply_variable_jump_gravity_v2(delta)

	# Coyote Time: Timer updaten
	# Kommentiere diese Zeilen aus, um Coyote Time zu deaktivieren
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Handle jump - Keyboard + Controller (BUTT_3 = A/Cross Button)
	var jump_pressed = (
		Input.is_action_just_pressed("ui_accept") or
		Input.is_action_just_pressed("BUTT_3")
	)
	# Normale Jump Bedingung ODER Coyote Time aktiv
	# <- Coyote Time
	# (auskommentieren zum Deaktivieren)
	var can_jump = is_on_floor() or coyote_timer > 0.0
	# <- Ohne Coyote Time
	# (entkommentieren zum Deaktivieren)
	# var can_jump = is_on_floor()

	if jump_pressed and can_jump:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		jump_timer = 0.0
		coyote_timer = 0.0 # Timer zurücksetzen nach Jump

	# Get the input direction - Keyboard + Controller (Left Stick oder D-Pad)
	var direction := 0.0

	# Linker Analog Stick (STICK_L_X)
	if Input.get_action_strength("STICK_L_X") != 0.0:
		direction = Input.get_axis("", "STICK_L_X") # Negative = Links, Positive = Rechts
	# D-Pad als Fallback
	elif Input.is_action_pressed("DPAD_LEFT") or Input.is_action_pressed("DPAD_RIGHT"):
		direction = Input.get_axis("DPAD_LEFT", "DPAD_RIGHT")
	# Keyboard
	else:
		direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# VARIANTE 1: Wie der Unity Code mit Fall/Low Jump Multipliers
func apply_variable_jump_gravity_v1(delta: float) -> void:
	if not is_on_floor():
		var gravity = get_gravity()

		# Wenn der Spieler fällt (velocity.y > 0 in Godot, weil Y nach unten positiv ist)
		if velocity.y > 0:
			# Schnelleres Fallen
			velocity += gravity * FALL_MULTIPLIER * delta
		# Wenn der Spieler aufsteigt ABER Jump-Button losgelassen wurde
		elif velocity.y < 0:
			var jump_released = (
				not Input.is_action_pressed("ui_accept") and
				not Input.is_action_pressed("BUTT_3")
			)
			if jump_released:
				# Kürzerer Jump durch stärkere Gravitation
				velocity += gravity * LOW_JUMP_MULTIPLIER * delta
			else:
				# Normale Gravitation
				velocity += gravity * delta
		else:
			# Normale Gravitation
			velocity += gravity * delta
	else:
		is_jumping = false
		jump_timer = 0.0


# VARIANTE 2: Wie der Screenshot mit Jump Timer
func apply_variable_jump_gravity_v2(delta: float) -> void:
	if is_jumping:
		var jump_held = (
			Input.is_action_pressed("ui_accept") or
			Input.is_action_pressed("BUTT_3")
		)
		if jump_held and jump_timer < JUMP_HOLD_TIME:
			# Jump-Button wird gehalten - weiter springen
			jump_timer += delta
			var jump_strength = clamp(jump_timer / JUMP_HOLD_TIME, 0.0, 1.0)

			# Reduziere die Aufwärtsgeschwindigkeit langsamer
			if velocity.y < 0:
				velocity += get_gravity() * 0.5 * delta # Halbe Gravitation während Jump gehalten
		else:
			# Button losgelassen oder maximale Zeit erreicht - normale Gravitation
			is_jumping = false
			if not is_on_floor():
				velocity += get_gravity() * delta
	else:
		# Nicht am Springen - normale Gravitation wenn in der Luft
		if not is_on_floor():
			velocity += get_gravity() * delta
