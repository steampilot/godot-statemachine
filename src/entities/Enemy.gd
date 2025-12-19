extends CharacterBody2D
class_name Enemy
## Beispiel Enemy mit HealthComponent und VelocityComponent

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent

func _ready() -> void:
	# Health Signals verbinden
	health.health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_depleted)

	# Velocity Signals verbinden
	velocity_comp.velocity_changed.connect(_on_velocity_changed)

func _physics_process(_delta: float) -> void:
	# Movement wird von VelocityComponent gehandelt
	pass

func take_damage(amount: int) -> void:
	health.take_damage(amount)

func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
	print("Enemy: %d -> %d / %d HP" % [from, from - damage, max_hp])
	# UI Update, Damage-Flash, etc.

func _on_health_depleted() -> void:
	print("Enemy defeated!")
	die()

func _on_velocity_changed(new_velocity: Vector2) -> void:
	# Optional: Animation, Sound, etc.
	pass

func die() -> void:
	queue_free()
