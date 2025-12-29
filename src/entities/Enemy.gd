class_name Enemy

extends CharacterBody2D
## Beispiel Enemy mit HealthComponent und VelocityComponent
## Enemy CAN queue_free bei Death (nicht wie Player)

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent
@onready var death_comp: DeathComponent = $DeathComponent

func _ready() -> void:
	# Health Signals verbinden
	health.health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_depleted)

	# Velocity Signals verbinden
	velocity_comp.velocity_changed.connect(_on_velocity_changed)

	# Death ist OK für Enemy
	death_comp.auto_queue_free = true

func _physics_process(_delta: float) -> void:
	# Movement wird von VelocityComponent gehandelt
	pass

func take_damage(amount: int) -> void:
	health.take_damage(amount)

func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
	print("Enemy: %d -> %d / %d HP" % [from, from - damage, max_hp])
	# UI Update, Damage-Flash, etc.

func _on_health_depleted() -> void:
	print("Enemy defeated! DeathComponent wird queue_free aufrufen...")
	# DeathComponent handelt Death + queue_free

func _on_velocity_changed(_new_velocity: Vector2) -> void:
	# Optional: Animation, Sound, etc.
	pass
