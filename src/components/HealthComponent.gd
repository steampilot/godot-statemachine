extends Node
class_name HealthComponent
## Health Component - kann auf beliebige Nodes angewendet werden
## Player, Enemy, Kiste, Door, etc.

@export var max_health: int = 100
@export var current_health: int = 100

# Signals mit detaillierten Infos
signal health_changed(from_amount: int, damage_amount: int, of_max_amount: int)
signal health_depleted
signal health_restored(amount: int)

# Optionale Features
@export var invulnerable: bool = false
@export var invulnerability_duration: float = 0.0
var _invulnerability_timer: float = 0.0

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if invulnerable and _invulnerability_timer > 0:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0:
			invulnerable = false

## Schaden zufügen
func take_damage(damage: int) -> void:
	if invulnerable or current_health <= 0:
		return

	var from_health = current_health
	current_health = max(0, current_health - damage)

	health_changed.emit(from_health, damage, max_health)

	if current_health <= 0:
		health_depleted.emit()

## Heilen
func restore_health(amount: int) -> void:
	var old_health = current_health
	current_health = min(current_health + amount, max_health)
	var restored = current_health - old_health

	health_restored.emit(restored)
	health_changed.emit(old_health, -restored, max_health)

## Setter für Health
func set_health(value: int) -> void:
	var old_health = current_health
	current_health = clamp(value, 0, max_health)
	var change = current_health - old_health

	if change != 0:
		health_changed.emit(old_health, -change, max_health)

	if current_health <= 0:
		health_depleted.emit()

## Getter für Health
func get_health() -> int:
	return current_health

## Getter für Health Prozentsatz (0-100)
func get_health_percent() -> float:
	return (float(current_health) / float(max_health)) * 100.0

## Prüft ob noch lebendig
func is_alive() -> bool:
	return current_health > 0

## Invulnerabilität setzen
func set_invulnerable_for(duration: float) -> void:
	invulnerable = true
	_invulnerability_timer = duration

## Zurücksetzen
func reset() -> void:
	current_health = max_health
	invulnerable = false
	_invulnerability_timer = 0.0
