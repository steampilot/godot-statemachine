@tool
# Shape that defines the area that deals damage.
class_name HitBox
extends Area2D
@export var active: bool = true
@export var damage: int = 10


func _ready() -> void:
	# Connect to child_entered_tree signal to handle dynamically added shapes
	child_entered_tree.connect(_on_child_added)
	# Apply to existing children
	_apply_debug_color_to_all()

func _on_child_added(child: Node) -> void:
	# Automatically apply debug color when a new CollisionShape2D is added
	if child is CollisionShape2D:
		_apply_debug_color(child)

func _apply_debug_color_to_all() -> void:
	# Apply debug color to all existing CollisionShape2D children
	for child in get_children():
		if child is CollisionShape2D:
			_apply_debug_color(child)

func _apply_debug_color(shape: CollisionShape2D) -> void:
	# Set the debug color for a specific CollisionShape2D
	shape.debug_color = Color("00a6006b")
