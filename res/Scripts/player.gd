extends CharacterBody2D


var SPEED = 150.0
var JUMP_VELOCITY = -200.0

# Jump States - Definieren WIE wird gesprungen
enum JumpState {DEFAULT, MARIO, IRONMAN}
const JUMP_STATE_NAMES = {
	JumpState.DEFAULT: "Default",
	JumpState.MARIO: "Mario",
	JumpState.IRONMAN: "Iron Man"
}

# Jump Types - Definieren OB Jump erlaubt ist (Coyote Time)
enum JumpType {DEFAULT, COYOTE}
const JUMP_TYPE_NAMES = {
	JumpType.DEFAULT: "Default",
	JumpType.COYOTE: "Coyote Time"
}

# DEFAULT - Basic Jump
var DEFAULT_JUMP_VELOCITY = -200.0

# MARIO - Fall Multiplier (wie Unity Code)
var MARIO_JUMP_VELOCITY = -200.0
var MARIO_FALL_MULTIPLIER = 2.5 # Fällt schneller
var MARIO_LOW_JUMP_MULTIPLIER = 2.0 # Kurzer Jump, wenn Button losgelassen

# IRONMAN - Two-Phase Jump (Initial Phase + Boost Phase)
# Phase 1: Normale Jump-Phase (0.3 Sekunden)
var IRONMAN_INITIAL_VELOCITY = -200.0 # Jump-Kraft in der initialen Phase
var IRONMAN_INITIAL_HOLD_TIME = 0.3 # Dauer der initialen Jump-Phase

# Phase 2: Boost-Phase / Düsen-Phase (1 Sekunde)
var IRONMAN_BOOST_VELOCITY = -200.0 # Aufwärts-Geschwindigkeit während Boost
var IRONMAN_BOOST_HOLD_TIME = 1.0 # Maximale Dauer der Boost-Phase

# Coyote Time - Jump nach Verlassen der Kante
var COYOTE_TIME = 0.15 # Zeit in Sekunden nach Verlassen der Kante

var jump_timer = 0.0
var is_jumping = false
var coyote_timer = 0.0
var current_jump_state = JumpState.IRONMAN
var current_jump_type = JumpType.COYOTE
var debug_label: Label


func _ready() -> void:
	# Label unter dem Player finden
	if has_node("DebugLabel"):
		debug_label = get_node("DebugLabel")
		debug_label.modulate.a = 0.8 # Etwas transparent


func _physics_process(delta: float) -> void:
	# Handle Jump State switching - SELECT Button
	if Input.is_action_just_pressed("BUTT_5"): # SELECT Button
		current_jump_state = (current_jump_state + 1) % JumpState.size()

	# Handle Jump Type switching - START Button
	if Input.is_action_just_pressed("BUTT_4"): # START Button
		current_jump_type = (current_jump_type + 1) % JumpType.size()

	# Wende den aktuellen Jump-State an
	match current_jump_state:
		JumpState.DEFAULT:
			apply_jump_state_default(delta)
		JumpState.MARIO:
			apply_jump_state_mario(delta)
		JumpState.IRONMAN:
			apply_jump_state_ironman(delta)

	# Update Debug Label
	update_debug_label()

	# Coyote Time: Timer updaten (immer aktiv, aber nur verwendet wenn JumpType = COYOTE)
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Handle jump - Keyboard + Controller (BUTT_3 = A/Cross Button)
	var jump_pressed = (
		Input.is_action_just_pressed("ui_accept") or
		Input.is_action_just_pressed("BUTT_3")
	)

	# Can jump logic - abhängig vom JumpType
	var can_jump = false
	match current_jump_type:
		JumpType.DEFAULT:
			can_jump = is_on_floor()
		JumpType.COYOTE:
			can_jump = is_on_floor() or coyote_timer > 0.0

	if jump_pressed and can_jump:
		# Jump initialisierung - abhängig vom JumpState
		match current_jump_state:
			JumpState.DEFAULT:
				velocity.y = DEFAULT_JUMP_VELOCITY
			JumpState.MARIO:
				velocity.y = MARIO_JUMP_VELOCITY
			JumpState.IRONMAN:
				# Iron Man startet mit normaler Jump-Kraft
				velocity.y = IRONMAN_INITIAL_VELOCITY

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


func update_debug_label() -> void:
	if debug_label == null:
		return

	# Sammle Buttons die gerade gedrückt sind
	var pressed_buttons = []

	if Input.is_action_pressed("ui_left"):
		pressed_buttons.append("LEFT")
	if Input.is_action_pressed("ui_right"):
		pressed_buttons.append("RIGHT")
	if Input.is_action_pressed("ui_accept"):
		pressed_buttons.append("JUMP")
	if Input.is_action_pressed("BUTT_3"):
		pressed_buttons.append("A")
	if Input.is_action_pressed("DPAD_LEFT"):
		pressed_buttons.append("D-LEFT")
	if Input.is_action_pressed("DPAD_RIGHT"):
		pressed_buttons.append("D-RIGHT")
	if Input.get_action_strength("STICK_L_X") > 0.5:
		pressed_buttons.append("STICK-RIGHT")
	elif Input.get_action_strength("STICK_L_X") < -0.5:
		pressed_buttons.append("STICK-LEFT")

	var buttons_text = "Buttons: " + (", ".join(pressed_buttons) if pressed_buttons.size() > 0 else "None")
	var state_text = "State: " + JUMP_STATE_NAMES[current_jump_state]
	var type_text = "Type: " + JUMP_TYPE_NAMES[current_jump_type]

	debug_label.text = buttons_text + "\n" + state_text + "\n" + type_text


# DEFAULT - Basic Jump mit normaler Gravitation
func apply_jump_state_default(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false
		jump_timer = 0.0


# MARIO - Fall Multiplier (wie Unity Code)
func apply_jump_state_mario(delta: float) -> void:
	if not is_on_floor():
		var gravity = get_gravity()

		# Wenn der Spieler fällt (velocity.y > 0 in Godot, weil Y nach unten positiv ist)
		if velocity.y > 0:
			# Schnelleres Fallen
			velocity += gravity * MARIO_FALL_MULTIPLIER * delta
		# Wenn der Spieler aufsteigt ABER Jump-Button losgelassen wurde
		elif velocity.y < 0:
			var jump_released = (
				not Input.is_action_pressed("ui_accept") and
				not Input.is_action_pressed("BUTT_3")
			)
			if jump_released:
				# Kürzerer Jump durch stärkere Gravitation
				velocity += gravity * MARIO_LOW_JUMP_MULTIPLIER * delta
			else:
				# Normale Gravitation
				velocity += gravity * delta
		else:
			# Normale Gravitation
			velocity += gravity * delta
	else:
		is_jumping = false
		jump_timer = 0.0


# IRONMAN - Two-Phase Jump
# Phase 1 (0-0.3s): Normaler Jump mit IRONMAN_INITIAL_VELOCITY
# Phase 2 (0.3-1.3s): Boost-Phase mit kontinuierlicher Aufladung (Düsen)
# Loslassen stoppt die Aufladung - normale Gravitation wirkt
func apply_jump_state_ironman(delta: float) -> void:
	if is_jumping:
		var jump_held = (
			Input.is_action_pressed("ui_accept") or
			Input.is_action_pressed("BUTT_3")
		)

		var total_boost_time = IRONMAN_INITIAL_HOLD_TIME + IRONMAN_BOOST_HOLD_TIME

		if jump_held and jump_timer < total_boost_time:
			jump_timer += delta

			# Phase 1: Initial Jump (erste 0.3 Sekunden)
			if jump_timer <= IRONMAN_INITIAL_HOLD_TIME:
				# Normale Jump-Phase - halbe Gravitation
				velocity += get_gravity() * 0.5 * delta
			# Phase 2: Boost/Düsen-Phase (danach bis 1.3 Sekunden)
			else:
				# Boost-Phase - kontinuierlich Aufwärts-Velocity addieren
				velocity.y += IRONMAN_BOOST_VELOCITY * delta
				# Limitiere die maximale Aufwärts-Geschwindigkeit während Boost
				velocity.y = max(velocity.y, IRONMAN_BOOST_VELOCITY * IRONMAN_BOOST_HOLD_TIME)
		else:
			# Button losgelassen oder maximale Zeit erreicht
			# Jetzt wirkt normale Gravitation (parabolisches Fallen)
			is_jumping = false
			velocity += get_gravity() * delta
	else:
		# Nicht am Springen - normale Gravitation wenn in der Luft
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			# Am Boden - Reset für nächsten Jump
			jump_timer = 0.0
