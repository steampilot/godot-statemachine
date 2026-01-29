extends Node
class_name PushableComponent
## Pushable Component - für Objekte die geschoben werden können
## Kisten, Steine, Blöcke, etc.

@export var push_force: float = 50.0
@export var friction: float = 0.9  # Bremsfaktor (0-1)
@export var max_push_speed: float = 200.0

var push_velocity: Vector2 = Vector2.ZERO
var parent_body: CharacterBody2D

signal pushed(direction: Vector2, force: float)
signal stopped

func _ready() -> void:
    parent_body = get_parent() as CharacterBody2D
    if not parent_body:
        push_error("PushableComponent muss Kind einer CharacterBody2D sein!")

func _physics_process(delta: float) -> void:
    if parent_body:
        # Reibung anwenden
        push_velocity *= friction

        # Wenn zu langsam, stoppen
        if push_velocity.length() < 1.0:
            push_velocity = Vector2.ZERO
            stopped.emit()

        parent_body.velocity = push_velocity
        parent_body.move_and_slide()

## Schiebt Objekt in Richtung
func push(direction: Vector2, force: float = -1.0) -> void:
    if force <= 0:
        force = push_force

    direction = direction.normalized()
    push_velocity = direction * clamp(force, 0.0, max_push_speed)

    pushed.emit(direction, force)

## Setzt Push-Geschwindigkeit direkt
func set_push_velocity(velocity: Vector2) -> void:
    push_velocity = velocity.clamp_length(0.0, max_push_speed)

## Getter für aktuelle Push-Velocity
func get_push_velocity() -> Vector2:
    return push_velocity

## Stoppt Bewegung sofort
func stop() -> void:
    push_velocity = Vector2.ZERO
    stopped.emit()

## Gibt Push-Speed Prozentsatz zurück (0-100)
func get_push_speed_percent() -> float:
    return (push_velocity.length() / max_push_speed) * 100.0
