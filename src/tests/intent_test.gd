extends Node
class_name IntentTest

## Unit Tests für Intent

func _ready() -> void:
	print("=== Intent Tests ===")
	test_intent_creation()
	test_intent_types()
	test_intent_values()
	test_intent_movement()
	test_intent_load_scene()
	print("=== Alle Tests bestanden ===\n")

func test_intent_creation() -> void:
	var intent = Intent.new(Intent.Type.MOVE)
	assert(intent != null, "Intent sollte erstellt werden")
	assert(intent.type == Intent.Type.MOVE, "Intent Type sollte gesetzt sein")
	print("✓ test_intent_creation bestanden")

func test_intent_types() -> void:
	var move_intent = Intent.new(Intent.Type.MOVE)
	var interact_intent = Intent.new(Intent.Type.INTERACT)
	var cancel_intent = Intent.new(Intent.Type.CANCEL)
	var load_scene_intent = Intent.new(Intent.Type.LOAD_SCENE)

	assert(move_intent.type == Intent.Type.MOVE, "MOVE Type sollte korrekt sein")
	assert(interact_intent.type == Intent.Type.INTERACT, "INTERACT Type sollte korrekt sein")
	assert(cancel_intent.type == Intent.Type.CANCEL, "CANCEL Type sollte korrekt sein")
	assert(load_scene_intent.type == Intent.Type.LOAD_SCENE, "LOAD_SCENE Type sollte korrekt sein")
	print("✓ test_intent_types bestanden")

func test_intent_values() -> void:
	var intent_with_value = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)
	assert(intent_with_value.value == Vector2.RIGHT, "Intent Value sollte gespeichert werden")

	var intent_without_value = Intent.new(Intent.Type.INTERACT)
	assert(intent_without_value.value == null, "Intent Value sollte null sein wenn nicht gesetzt")
	print("✓ test_intent_values bestanden")

func test_intent_movement() -> void:
	var move_up = Intent.new(Intent.Type.MOVE, Vector2.UP)
	var move_down = Intent.new(Intent.Type.MOVE, Vector2.DOWN)
	var move_left = Intent.new(Intent.Type.MOVE, Vector2.LEFT)
	var move_right = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)

	assert(move_up.value == Vector2.UP, "UP movement sollte korrekt sein")
	assert(move_down.value == Vector2.DOWN, "DOWN movement sollte korrekt sein")
	assert(move_left.value == Vector2.LEFT, "LEFT movement sollte korrekt sein")
	assert(move_right.value == Vector2.RIGHT, "RIGHT movement sollte korrekt sein")
	print("✓ test_intent_movement bestanden")

func test_intent_load_scene() -> void:
	var load_intent = Intent.new(Intent.Type.LOAD_SCENE, "res://src/scenes/main.tscn")
	assert(load_intent.type == Intent.Type.LOAD_SCENE, "Type sollte LOAD_SCENE sein")
	assert(load_intent.value == "res://src/scenes/main.tscn", "Scene path sollte gespeichert sein")
	print("✓ test_intent_load_scene bestanden")
