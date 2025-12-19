extends CharacterBody2D
class_name PlayerEntity
## Beispiel Player mit HealthComponent und VelocityComponent

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent
@onready var intent_emitter: IntentEmitter = $IntentEmitter

func _ready() -> void:
	# Health Signals
	health.health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_depleted)

	# Velocity Signals
	velocity_comp.velocity_changed.connect(_on_velocity_changed)

func _process(_delta: float) -> void:
	# Intent-basierte Eingabe
	var intents = intent_emitter.collect()
	for intent in intents:
		handle_intent(intent)

func handle_intent(intent: Intent) -> void:
	match intent.type:
		Intent.Type.MOVE:
			velocity_comp.set_direction(intent.value)
		Intent.Type.INTERACT:
			interact()
		Intent.Type.CANCEL:
			velocity_comp.stop()

func interact() -> void:
	print("Player interacted!")

func take_damage(amount: int) -> void:
	health.take_damage(amount)

func heal(amount: int) -> void:
	health.restore_health(amount)

func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
	var percent = health.get_health_percent()
	print("Player: %d -> %d / %d HP (%.0f%%)" % [from, from - damage, max_hp, percent])
	# HUD Update, Damage-Flash, etc.

func _on_health_depleted() -> void:
	print("Player defeated!")
	die()

func _on_velocity_changed(new_velocity: Vector2) -> void:
	# Animation, Footsteps, etc.
	pass

func die() -> void:
	print("Game Over!")
	# Reset Level, Show Game Over Screen, etc.
	queue_free()
