extends Node2D
@export var max_health = 100
@export var health = max_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func receive_damage(amount: int) -> void:
	print("%d received %d damage!", [% owner.name, amount])
	health -= amount
	if health <= 0:
		print("%d has been defeated!", [% owner.name])
		queue_free()
