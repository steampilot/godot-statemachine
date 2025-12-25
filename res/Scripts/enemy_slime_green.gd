extends Node2D
@export var max_health = 100
@export var health = max_health

@onready var sprite: AnimatedSprite2D = %Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func receive_damage(amount: int) -> void:
	print("%s received %d damage!" % [self.name, amount])
	health -= amount
	print("%s Is now at health: %d of %d" % [self.name, health, max_health])
	sprite.play("hurt")
	if health <= 0:
		print("%s has been defeated!" % [self.name])
		queue_free()
