extends CharacterBody2D

# Available Controls
# Keyboard: Arrow Keys (Left/Right), Space (Jump), Mouse Left (Attack)
# Controller (Xbox): A Button (Jump), X Button (Attack), DPAD/Left Stick (Movement)

# ========== STATE MACHINES ==========
# Player State (Alive, Dead, Invincible, etc.)
enum PlayerState {
	ALIVE,
	DEAD,
	INVINCIBLE,
	STUNNED
}

# Movement State (Idle, Running, Jumping, etc.)
enum MovementState {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	LANDING
}

# Animation State (korrespondiert mit Movement State)
enum AnimationState {
	IDLE,
	RUN,
	JUMP_ASCEND,
	JUMP_PEAK,
	JUMP_DESCEND,
	LAND
}

# ========== RUNNING VARIABLES ==========
# Maximale Laufgeschwindigkeit
var max_speed = 300.0
# Wie schnell beschleunigt der Spieler
var acceleration = 1800.0
# Wie schnell bremst der Spieler beim Loslassen
var deceleration = 1400.0
# Richtungswechsel-Faktor (0.0 - 1.0) multipliziert mit (deceleration + acceleration)
var turn_speed = 1.0
# Sofortige Bewegung (kein Acceleration)
var instant_movement = false

# ========== JUMP VARIABLES ==========
# Basic Jump Settings
# Sprunghöhe in Pixeln (wird zu upward velocity konvertiert)
var jump_height = 64.0 # Default: 100 Pixel
# Zeit bis zum höchsten Punkt des Sprungs (berechnet Gravitation)
var jump_duration = 0.5 # Default: 0.5 Sekunden

# Air Control - NUR horizontale (X) Bewegung in der Luft!
# Horizontale Beschleunigung in der Luft (0.0 - 1.0) als Faktor von acceleration
var air_acceleration = 0.5
# Kontrolle in der Luft (0.0 = keine, 1.0 = volle Kontrolle)
var air_control = 0.8
# Horizontale Bremskraft in der Luft (0.0 - 1.0) als Faktor von deceleration
var air_brake = 0.6

# Gravity Settings
# Gravity-Multiplikator beim Fallen (nach Peak des Jumps)
var down_gravity_multiplier = 2.0
# Maximale Fallgeschwindigkeit (verhindert endloses Beschleunigen)
var terminal_velocity = 1000.0

# Variable Jump Height
# Variable Sprunghöhe aktiv
var variable_jump_height = true
# Extra Gravitation wenn Jump-Button losgelassen (Amount of extra force)
var jump_cutoff_multiplier = 4.0

# Double Jump
# Erlaubt zweiten Sprung in der Luft
var double_jump_enabled = false
# Anzahl verfügbarer Double Jumps
var double_jumps_available = 1

# ========== ASSIST VARIABLES (Gameplay Hilfen) ==========
# Zeit nach Kantenverlassen, in der Jump noch möglich ist
var coyote_time = 0.15
# Zeit vor Landung, in der Jump gepuffert wird
var jump_buffer_time = 0.1

# ========== CAMERA VARIABLES ==========
# True = Kamera bewegt sich nicht, False = Kamera folgt Player
var camera_fixed = false
# True = Kamera folgt nur horizontal + nur bei Platform-Wechsel vertikal
var camera_ignores_jump = true

# Camera Smoothing (Damping)
# Smoothing für horizontale Bewegung (höher = langsamer)
var camera_damping_x = 5.0
# Smoothing für vertikale Bewegung (höher = langsamer)
var camera_damping_y = 3.0

# Camera Lookahead
# Pixel-Offset in Bewegungsrichtung (0 = kein Lookahead)
var camera_lookahead = 100.0
# Wie schnell der Lookahead-Offset sich anpasst
var camera_lookahead_speed = 2.0

# Camera Zoom
# Zoom-Level (1.0 = normal, 2.0 = näher, 0.5 = weiter weg)
var camera_zoom = 1.0

# Camera Ghost Target
# Position die Kamera folgt (nur wenn camera_ignores_jump = true)
# Wird horizontal immer aktualisiert, vertikal nur bei Landung auf neuer Plattform
var camera_ghost_position = Vector2.ZERO
# Letzte Y-Position auf dem Boden (für Platform-Wechsel Detection)
var last_grounded_y = 0.0

# Camera Jump Ignore Limits - Folgt nach Zeit oder bei zu großer Distanz
# Max Y-Distanz bevor Kamera folgt (große Sprünge/Klippen)
var camera_max_vertical_distance = 200.0
# Max Zeit ohne Folgen, dann folgt Kamera trotzdem
var camera_max_ignore_time = 2.0
# Timer für Ignore-Zeit
var camera_ignore_timer = 0.0

# ========== ADDITIONALS (Visual & Audio - Noch nicht implementiert) ==========
# Particle Effects
# Partikel beim Rennen
var particle_running_enabled = true
# Partikel beim Sprung
var particle_jumping_enabled = true
# Partikel beim Landen
var particle_landing_enabled = true
# Partikel beim Double Jump
var particle_doublejump_enabled = true

# Squash and Stretch
# Squash & Stretch aktivieren
var squash_stretch_enabled = true
# Squash Amount beim Sprung (0.0 - 1.0)
var squash_on_jump = 0.2
# Stretch Amount beim Sprung (0.0 - 1.0)
var stretch_on_jump = 0.3
# Squash Amount beim Landen (0.0 - 1.0)
var squash_on_land = 0.4
# Dauer der Squash/Stretch Animation
var squash_duration = 0.1

# Trail Effect
# Trail aktivieren
var trail_enabled = true
# Trail beim Springen
var trail_on_jump = true
# Trail beim schnellen Rennen
var trail_on_run = true
# Trail Intensität (0.0 - 1.0)
var trail_intensity = 0.5
# Wie lange Trail sichtbar bleibt
var trail_duration = 0.3

# Sound Effects (Pfade zu AudioStream Resources)
# Jump Sound aktivieren
var sfx_jump_enabled = true
# Land Sound aktivieren
var sfx_land_enabled = true
# Double Jump Sound aktivieren
var sfx_doublejump_enabled = true
# Jump Sound Resource
var sfx_jump: AudioStream = null
# Land Sound Resource
var sfx_land: AudioStream = null
# Double Jump Sound Resource
var sfx_doublejump: AudioStream = null

# Current States
var player_state: PlayerState = PlayerState.ALIVE
var movement_state: MovementState = MovementState.IDLE
var animation_state: AnimationState = AnimationState.IDLE

# ========== STATE ==========
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
# Für Landing Detection
var was_on_floor = false

# Calculated values (werden in _ready() berechnet)
# Berechnete Sprunggeschwindigkeit (upward acceleration)
var _jump_velocity = 0.0
# Berechnete Gravitation
var _gravity = 0.0
# Verbleibende Jumps (für Double Jump)
var _jumps_remaining = 0

# Node References
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var weapon: Node2D = $PlayerWeaponSword if has_node("PlayerWeaponSword") else null


func _ready() -> void:
	add_to_group("player")

	# Berechne Jump Physics aus Height und Duration
	calculate_jump_physics()

	# Initialisiere Camera Ghost Position
	camera_ghost_position = global_position
	last_grounded_y = global_position.y

	# Initialisiere Double Jump Counter
	_jumps_remaining = double_jumps_available


func calculate_jump_physics() -> void:
	# Berechnet jump_velocity und gravity aus jump_height und jump_duration.
	# Basiert auf kinematischen Gleichungen:
	# - v = 2h/t (velocity to reach height h in time t)
	# - g = 2h/t² (gravity needed)
	_jump_velocity = - (2.0 * jump_height) / jump_duration
	_gravity = (2.0 * jump_height) / (jump_duration * jump_duration)


func _physics_process(delta: float) -> void:
	# Check if player is alive
	if player_state != PlayerState.ALIVE:
		return

	# Update Movement State
	update_movement_state()

	# Apply Gravity (mit Variable Jump Height)
	apply_gravity(delta)

	# Update Timers
	update_timers(delta)

	# Handle Attack Input
	handle_attack()

	# Handle Jump
	handle_jump()

	# Handle Movement
	handle_movement(delta)

	# Update Camera Ghost Position
	update_camera_ghost()

	# Update Animation State
	update_animation_state()

	# Store floor state for next frame
	was_on_floor = is_on_floor()

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		# Verwende berechnete Gravitation
		var gravity_force = _gravity

		# Down Gravity - schnelleres Fallen nach Jump-Peak
		if velocity.y > 0:
			gravity_force *= down_gravity_multiplier

		# Variable Jump Height - Extra Gravitation wenn Button losgelassen
		if variable_jump_height and velocity.y < 0:
			var jump_released = (
				not Input.is_action_pressed("ui_accept") and
				not Input.is_action_pressed("BUTT_2")
			)
			if jump_released:
				# Jump Cutoff - starke Gravitation beim Loslassen
				gravity_force *= jump_cutoff_multiplier

		# Apply Gravity
		velocity.y += gravity_force * delta

		# Terminal Velocity - Limitiere maximale Fallgeschwindigkeit
		if velocity.y > terminal_velocity:
			velocity.y = terminal_velocity
	else:
		# Auf dem Boden - Reset Double Jumps
		_jumps_remaining = double_jumps_available


func update_timers(delta: float) -> void:
	# Coyote Timer
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump Buffer Timer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

func handle_attack() -> void:
	# Handhabt Attack Input und triggert Weapon
	if not weapon:
		return

	var attack_pressed = (
		Input.is_action_just_pressed("attack") or
		Input.is_action_just_pressed("BUTT_1")
	)


	if attack_pressed and weapon.can_attack():
		weapon.attack()
		# Trigger Strike Animation auf Player
		if sprite and movement_state != MovementState.JUMPING and movement_state != MovementState.FALLING:
			sprite.play("strike")


func handle_movement(delta: float) -> void:
	# Get input direction
	var direction := get_input_direction()

	# Unterscheide zwischen Ground und Air Movement
	var is_airborne = not is_on_floor()

	if instant_movement:
		# Instant Movement - Kein Acceleration
		velocity.x = direction * max_speed
	else:
		# Smooth Movement mit Acceleration/Deceleration
		if direction != 0.0:
			# Bewegung in eine Richtung
			var target_speed = direction * max_speed

			# Wähle Acceleration basierend auf Air/Ground
			var accel = acceleration * air_acceleration if is_airborne else acceleration

			# Apply Air Control Multiplier
			if is_airborne:
				accel *= air_control

			# Prüfe ob wir die Richtung wechseln (z.B. von rechts nach links)
			var is_turning = sign(velocity.x) != sign(direction) and velocity.x != 0.0

			if is_turning:
				# Schnellere Richtungsänderung mit turn_speed
				var turn_accel = (deceleration + acceleration) * turn_speed
				velocity.x = move_toward(velocity.x, target_speed, turn_accel * delta)
			else:
				# Normale Beschleunigung
				velocity.x = move_toward(velocity.x, target_speed, accel * delta)
		else:
			# Keine Input - Deceleration
			var decel = deceleration * air_brake if is_airborne else deceleration
			velocity.x = move_toward(velocity.x, 0.0, decel * delta)


func get_input_direction() -> float:
	var direction := 0.0

	# Linker Analog Stick (höchste Priorität)
	if Input.get_action_strength("STICK_L_X") != 0.0:
		direction = Input.get_axis("", "STICK_L_X")
	# D-Pad als Fallback
	elif Input.is_action_pressed("DPAD_LEFT") or Input.is_action_pressed("DPAD_RIGHT"):
		direction = Input.get_axis("DPAD_LEFT", "DPAD_RIGHT")
	# Keyboard
	else:
		direction = Input.get_axis("ui_left", "ui_right")

	return direction


func handle_jump() -> void:
	var jump_pressed = (
		Input.is_action_just_pressed("ui_accept") or
		Input.is_action_just_pressed("BUTT_2")
	)

	# Jump Buffer - Speichere Jump-Input kurz vor Landung
	if jump_pressed:
		jump_buffer_timer = jump_buffer_time

	# Can jump mit Coyote Time, Jump Buffer oder Double Jump
	var can_coyote_jump = coyote_timer > 0.0
	var can_buffered_jump = is_on_floor() and jump_buffer_timer > 0
	var can_double_jump = double_jump_enabled and _jumps_remaining > 0 and not is_on_floor()

	# Normal Jump (Coyote oder Buffered)
	if (can_coyote_jump or can_buffered_jump) and jump_buffer_timer > 0:
		perform_jump()
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
	# Double Jump
	elif can_double_jump and jump_pressed:
		perform_jump()
		_jumps_remaining -= 1


func perform_jump() -> void:
	# Führt einen Sprung aus mit berechneter jump_velocity
	velocity.y = _jump_velocity


func update_camera_ghost() -> void:
	# Updates the camera ghost position for smooth camera follow.
	# Horizontal: Immer aktualisiert (folgt Player sofort)
	# Vertikal:
	#	- Wenn camera_ignores_jump = false: Folgt Player sofort
	#	- Wenn camera_ignores_jump = true: Nur bei Landung auf neuer Plattform
	#	ABER folgt bei großen vertikalen Distanzen oder nach Timer
	#
	if camera_ignores_jump:
		# Horizontal: Immer folgen
		camera_ghost_position.x = global_position.x

		# Berechne vertikale Distanz zwischen Ghost und Player
		var vertical_distance = abs(global_position.y - camera_ghost_position.y)

		# Update Timer wenn in der Luft und Ghost nicht folgt
		if not is_on_floor() and vertical_distance > 10.0:
			camera_ignore_timer += get_process_delta_time()
		else:
			camera_ignore_timer = 0.0

		# FORCE FOLLOW Bedingungen - Kamera folgt trotz ignore_jump:
		# 1. Zu große vertikale Distanz (große Sprünge/Klippen)
		# 2. Zu lange Zeit ohne Folgen
		var force_follow_distance = vertical_distance > camera_max_vertical_distance
		var force_follow_time = camera_ignore_timer > camera_max_ignore_time

		if force_follow_distance or force_follow_time:
			# Force Follow - Kamera folgt sofort vertikal
			camera_ghost_position.y = global_position.y
			camera_ignore_timer = 0.0
		# Normale Bedingungen - Landung auf neuer Plattform
		elif is_on_floor() and not was_on_floor:
			# Gerade gelandet - prüfe ob auf neuer Plattform
			var y_difference = abs(global_position.y - last_grounded_y)

			# Wenn Y-Unterschied groß genug (z.B. > 10 Pixel), neue Plattform
			if y_difference > 10.0:
				camera_ghost_position.y = global_position.y
				last_grounded_y = global_position.y
		elif is_on_floor():
			# Auf Boden bleiben - Ghost folgt
			camera_ghost_position.y = global_position.y
			last_grounded_y = global_position.y
	else:
		# Kamera folgt direkt ohne Ghost
		camera_ghost_position = global_position
		camera_ignore_timer = 0.0


# ========== STATE MACHINE FUNCTIONS ==========

func update_movement_state() -> void:
	# Aktualisiert den Movement State basierend auf Spieler-Zustand
	var was_jumping = movement_state == MovementState.JUMPING
	var was_falling = movement_state == MovementState.FALLING

	if is_on_floor():
		# Auf dem Boden
		if (was_jumping or was_falling) and movement_state != MovementState.LANDING:
			# Gerade gelandet
			movement_state = MovementState.LANDING
		elif movement_state == MovementState.LANDING:
			# Landing Animation läuft noch
			pass
		elif abs(velocity.x) > 10.0:
			# Bewegung
			movement_state = MovementState.RUNNING
		else:
			# Stillstand
			movement_state = MovementState.IDLE
	else:
		# In der Luft
		if velocity.y < 0:
			# Aufsteigend
			movement_state = MovementState.JUMPING
		else:
			# Fallend
			movement_state = MovementState.FALLING


func update_animation_state() -> void:
	# Aktualisiert den Animation State und spielt entsprechende Animation ab
	if not sprite:
		return

	var new_anim_state = animation_state
	var peak_threshold = 50.0

	# Bestimme neue Animation basierend auf Movement State
	match movement_state:
		MovementState.IDLE:
			new_anim_state = AnimationState.IDLE

		MovementState.RUNNING:
			new_anim_state = AnimationState.RUN

		MovementState.JUMPING:
			if abs(velocity.y) < peak_threshold:
				new_anim_state = AnimationState.JUMP_PEAK
			else:
				new_anim_state = AnimationState.JUMP_ASCEND

		MovementState.FALLING:
			new_anim_state = AnimationState.JUMP_DESCEND

		MovementState.LANDING:
			new_anim_state = AnimationState.LAND

	# Spiele Animation ab wenn State sich geändert hat
	if new_anim_state != animation_state:
		animation_state = new_anim_state
		play_animation(animation_state)

	# Update Running Animation Speed basierend auf Geschwindigkeit
	if animation_state == AnimationState.RUN:
		update_run_animation_speed()

	# Flip Sprite basierend auf Bewegungsrichtung
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


func update_run_animation_speed() -> void:
	# Passt die Geschwindigkeit der Running-Animation basierend auf der aktuellen Geschwindigkeit an.
	# Animation Speed wird zwischen 8 und 16 FPS geclampd.
	if not sprite:
		return

	# Berechne Speed-Faktor basierend auf aktueller Geschwindigkeit vs max_speed
	var speed_ratio = abs(velocity.x) / max_speed

	# Map speed_ratio (0.0 - 1.0) zu FPS Range (8 - 16)
	var min_fps = 8.0
	var max_fps = 16.0
	var target_fps = lerp(min_fps, max_fps, speed_ratio)

	# AnimatedSprite2D verwendet speed_scale (default FPS * speed_scale)
	# Wir nehmen an, dass die Run-Animation mit 12 FPS designed wurde
	var base_fps = 12.0
	sprite.speed_scale = target_fps / base_fps


func play_animation(anim_state: AnimationState) -> void:
	# Spielt die entsprechende Animation für den Animation State ab
	if not sprite:
		return

	match anim_state:
		AnimationState.IDLE:
			sprite.play("idle")
			sprite.speed_scale = 1.0

		AnimationState.RUN:
			sprite.play("run")
			# Speed wird in update_run_animation_speed() gesetzt

		AnimationState.JUMP_ASCEND:
			sprite.play("jump_ascend")
			sprite.speed_scale = 1.0

		AnimationState.JUMP_PEAK:
			sprite.play("jump_peak")
			sprite.speed_scale = 1.0

		AnimationState.JUMP_DESCEND:
			sprite.play("jump_descend")
			sprite.speed_scale = 1.0

		AnimationState.LAND:
			sprite.play("jump_land")
			sprite.speed_scale = 1.0
			# Nach Landing Animation zurück zu IDLE/RUNNING
			await sprite.animation_finished
			if is_on_floor():
				if abs(velocity.x) > 10.0:
					movement_state = MovementState.RUNNING
				else:
					movement_state = MovementState.IDLE


func set_player_state(new_state: PlayerState) -> void:
	# Wechselt den Player State
	if player_state == new_state:
		return

	# Exit current state
	match player_state:
		PlayerState.ALIVE:
			pass
		PlayerState.DEAD:
			pass
		PlayerState.INVINCIBLE:
			pass
		PlayerState.STUNNED:
			pass

	# Enter new state
	player_state = new_state
	match player_state:
		PlayerState.ALIVE:
			pass
		PlayerState.DEAD:
			# Stop movement
			velocity = Vector2.ZERO
			# Play death animation
			if sprite:
				sprite.play("death")
		PlayerState.INVINCIBLE:
			# Visual feedback (z.B. Blinken)
			pass
		PlayerState.STUNNED:
			# Stop movement
			velocity.x = 0


func update_jump_animation() -> void:
	# Aktualisiert die Sprung-Animation basierend auf vertikaler Geschwindigkeit.
	# Animationen: jump_ascend, jump_peak, jump_descend
	if not sprite:
		return

	if not is_on_floor():
		# Threshold für Peak Detection (nahe 0 velocity)
		var peak_threshold = 50.0

		if abs(velocity.y) < peak_threshold:
			# Am höchsten Punkt (Peak)
			if sprite.animation != "jump_peak":
				sprite.play("jump_peak")
		elif velocity.y < 0:
			# Aufsteigend
			if sprite.animation != "jump_ascend":
				sprite.play("jump_ascend")
		else:
			# Fallend
			if sprite.animation != "jump_descend":
				sprite.play("jump_descend")
