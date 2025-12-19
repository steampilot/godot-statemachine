extends Node
class_name DeathComponent
## Death Handling Component
## Separiert Death-Logic von Health
## Ermöglicht: Ragdoll, Particle, Sound, Animation vor Destroy

@export var death_animation_duration: float = 1.0
@export var auto_queue_free: bool = false  # FALSE für Player!
@export var on_death_callback: Callable = Callable()

var parent_node: Node
var is_dead: bool = false

signal death_started
signal death_finished

func _ready() -> void:
	parent_node = get_parent()

	# Wenn Parent ein HealthComponent hat, verbinde Death
	var health_comp = parent_node.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.health_depleted.connect(_on_health_depleted)

func _on_health_depleted() -> void:
	if is_dead:
		return

	handle_death()

## Hauptfunktion für Death-Handling
func handle_death() -> void:
	is_dead = true
	death_started.emit()

	print("%s started death sequence" % parent_node.name)

	# Death Animation/Effects hier
	if death_animation_duration > 0:
		await get_tree().create_timer(death_animation_duration).timeout

	# Callback wenn vorhanden
	if on_death_callback.is_valid():
		on_death_callback.call()

	death_finished.emit()

	# Nur wenn auto_queue_free = true (nicht für Player!)
	if auto_queue_free:
		parent_node.queue_free()
	else:
		# Für Player: Disable Input, Fade Out, etc. aber NICHT queue_free
		_disable_entity()

## Disablet Entity aber entfernt sie nicht
func _disable_entity() -> void:
	# Disable Physics
	var char_body = parent_node as CharacterBody2D
	if char_body:
		char_body.process_mode = Node.PROCESS_MODE_DISABLED

	# Optional: Fade-Effekt
	if parent_node.has_node("Sprite2D"):
		var sprite = parent_node.get_node("Sprite2D")
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.3, 1.0)

## Manuell Death triggern
func trigger_death() -> void:
	handle_death()

## Prüft ob tot
func is_dead_check() -> bool:
	return is_dead
