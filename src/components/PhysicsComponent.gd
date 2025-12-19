extends Node
class_name PhysicsComponent
## Physics Component - für Gravity, Jump, Forces
## Alle Forces sind POSITIV, Vorzeichen wird beim Anwenden berechnet

@export var gravity: float = 980.0  # Positive Gravitation nach unten
@export var jump_force: float = 0.0  # Positive Jump Force nach oben
@export var max_fall_speed: float = 500.0
@export var use_gravity: bool = true

var parent_body: CharacterBody2D
var vertical_velocity: float = 0.0  # Intern berechnet
var is_jumping: bool = false

signal jumped(force: float)
signal landed
signal velocity_changed(velocity: Vector2)

func _ready() -> void:
	parent_body = get_parent() as CharacterBody2D
	if not parent_body:
		push_error("PhysicsComponent muss Kind einer CharacterBody2D sein!")

func _physics_process(delta: float) -> void:
	if not parent_body:
		return

	# Gravitation anwenden (NEGATIV für nach unten im Godot-Koordinatensystem)
	if use_gravity:
		vertical_velocity += gravity * delta  # Positive Gravitation wird zu negativer Velocity
		vertical_velocity = min(vertical_velocity, max_fall_speed)  # Cap fall speed

	# Vertical Velocity in CharacterBody2D setzen
	var current_vel = parent_body.velocity
	current_vel.y = vertical_velocity
	parent_body.velocity = current_vel
	parent_body.move_and_slide()

	# Landed Check
	if parent_body.is_on_floor() and is_jumping:
		is_jumping = false
		landed.emit()

## Jump - Force ist POSITIV
func jump(force: float = -1.0) -> void:
	if force <= 0:
		force = jump_force

	if not parent_body.is_on_floor():
		return

	# NEGATIV weil in Godot ist nach oben negativ Y
	vertical_velocity = -force
	is_jumping = true
	jumped.emit(force)

## Apply externe Force (POSITIV = nach oben, NEGATIV = nach unten)
func apply_vertical_force(force: float) -> void:
	vertical_velocity = force

## Setter für Vertical Velocity (intern, für Spezialfälle)
func set_vertical_velocity(velocity: float) -> void:
	vertical_velocity = velocity

## Getter
func get_vertical_velocity() -> float:
	return vertical_velocity

## Prüft ob im Air
func is_in_air() -> bool:
	return not parent_body.is_on_floor()

## Prüft ob auf Boden
func is_on_floor() -> bool:
	return parent_body.is_on_floor()

## Prüft ob springt
func is_jumping_now() -> bool:
	return is_jumping

## Setzt Velocity auf 0
func stop_vertical_movement() -> void:
	vertical_velocity = 0.0
	if parent_body.is_on_floor():
		is_jumping = false
