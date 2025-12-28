class_name Player
extends CharacterBody2D

@export var max_health: int = 100

## Jump Release Gravity Multiplikator - 
## erhöhte Fallgeschwindigkeit wenn Jump-Button losgelassen wird
## Ermöglicht präzise Jump-Stomp-Attacken (höher = schnellerer Fall)
@export var jump_release_gravity_multiplier: float = 3.0
@export var max_speed: float = 150.0
## Acceleration als Multiplikator der max_speed (6.0 = erreicht max_speed in 1/6 Sekunde)
@export var acceleration: float = 6.0
## Deceleration als Multiplikator der max_speed
@export var deceleration: float = 4.5
## Turn speed Multiplikator für schnellere Richtungswechsel
@export var turn_speed: float = 1.5
## Air control Multiplikator - wie viel Kontrolle in der Luft (0.0-1.0)
@export var air_control: float = 0.65
## Jump height in Pixeln - maximale Sprunghöhe wenn Button gehalten wird
@export var jump_height: float = 80.0
## Coyote time - Zeit nach Verlassen der Plattform, in der noch gesprungen werden kann (Sekunden)
@export var coyote_time: float = 0.15

# Internal timer for coyote time
var coyote_timer: float = 0.0

# Air dash limiter - can only dash once per air time
var can_air_dash: bool = true


var health: int = max_health

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var state_machine: StateMachine = %StateMachine

func _ready() -> void:
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	# Apply gravity centrally (Celeste-style)
	# States control gravity_multiplier for variable fall speed
	var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
	var grav_mult = state_machine.current_state.gravity_multiplier if state_machine.current_state else 1.0
	velocity.y += gravity * grav_mult * delta
	
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func receive_damage(amount: int) -> void:
	print("%s received %d damage!" % [self.name, amount])
	health -= amount
	print("%s Is now at health: %d of %d" % [self.name, health, max_health])
	sprite.play("hurt")
	if health <= 0:
		print("%s has been defeated!" % [self.name])

## Get dash direction based on current input state
## Returns normalized Vector2 or Vector2.ZERO if no valid dash input
func get_dash_direction() -> Vector2:
	var dir := Vector2.ZERO
	
	# Get horizontal input
	var h_input = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)
	# Get vertical input (Godot: Y negative = up, Y positive = down)
	var v_up = -1.0 if Input.is_action_pressed(INPUT_ACTIONS.MOVE_UP) else 0.0
	var v_down = 1.0 if Input.is_action_pressed(INPUT_ACTIONS.MOVE_DOWN) else 0.0
	var v_input = v_up + v_down
	
	# On ground: Only horizontal or down dash allowed
	if is_on_floor():
		if v_input > 0: # Down pressed (positive Y)
			# Ground slide - horizontal in sprite direction
			dir.x = 1.0 if not sprite.flip_h else -1.0
			dir.y = 0.0
		return dir
	
	# In air: All 8 directions possible
	if can_air_dash:
		dir.x = h_input
		dir.y = v_input
		
		# If no direction at all, dash in sprite direction (horizontal)
		if dir.length_squared() == 0:
			dir.x = 1.0 if not sprite.flip_h else -1.0
		
		return dir.normalized()
	
	return Vector2.ZERO
