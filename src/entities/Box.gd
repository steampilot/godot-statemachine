extends CharacterBody2D
class_name Box
## Beispiel Box/Kiste mit HealthComponent und PushableComponent

@onready var health: HealthComponent = $HealthComponent
@onready var pushable: PushableComponent = $PushableComponent

func _ready() -> void:
	# Health Signals
	health.health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_depleted)

	# Pushable Signals
	pushable.pushed.connect(_on_pushed)
	pushable.stopped.connect(_on_stopped)

func _physics_process(_delta: float) -> void:
	# Bewegung wird von PushableComponent gehandelt
	pass

func push_box(direction: Vector2, force: float = -1.0) -> void:
	pushable.push(direction, force)

func take_damage(amount: int) -> void:
	health.take_damage(amount)

func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
	print("Box: %d -> %d / %d HP" % [from, from - damage, max_hp])

func _on_health_depleted() -> void:
	print("Box destroyed!")
	destroy()

func _on_pushed(direction: Vector2, force: float) -> void:
	print("Box pushed in direction: %s with force: %.1f" % [direction, force])
	# Dust particles, Sound, etc.

func _on_stopped() -> void:
	print("Box stopped moving")

func destroy() -> void:
	# Explosion, Sound, Particle, etc.
	queue_free()
