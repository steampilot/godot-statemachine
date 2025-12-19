extends Node
class_name VelocityComponent
## Velocity Component - für bewegliche Objekte
## Player, Enemy, Projectile, etc.

@export var direction: Vector2 = Vector2.ZERO
@export var speed: float = 100.0
@export var acceleration: float = 0.0  # Optional: für Beschleunigung
@export var max_speed: float = 500.0

var current_velocity: Vector2 = Vector2.ZERO
var parent_body: CharacterBody2D

signal velocity_changed(new_velocity: Vector2)
signal speed_changed(new_speed: float)

func _ready() -> void:
	parent_body = get_parent() as CharacterBody2D
	if not parent_body:
		push_error("VelocityComponent muss Kind einer CharacterBody2D sein!")

func _physics_process(_delta: float) -> void:
	if parent_body and not direction.is_zero_approx():
		current_velocity = direction * speed
		parent_body.velocity = current_velocity
		parent_body.move_and_slide()
		velocity_changed.emit(current_velocity)

## Setter für Direction
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

## Setter für Speed
func set_speed(new_speed: float) -> void:
	speed = clamp(new_speed, 0.0, max_speed)
	speed_changed.emit(speed)

## Getter für Velocity
func get_velocity() -> Vector2:
	return current_velocity

## Getter für Speed
func get_speed() -> float:
	return speed

## Stoppt Bewegung
func stop() -> void:
	direction = Vector2.ZERO
	current_velocity = Vector2.ZERO

## Beschleunigt
func accelerate(delta: float) -> void:
	if acceleration > 0:
		set_speed(speed + acceleration * delta)

## Verzögert
func decelerate(delta: float) -> void:
	if acceleration > 0:
		set_speed(speed - acceleration * delta)

## Gibt Richtung zurück (normalisiert)
func get_direction() -> Vector2:
	return direction.normalized()
