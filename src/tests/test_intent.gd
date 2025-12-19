extends GutTest

## Unit Tests für Intent mit GUT

func test_intent_creation() -> void:
	var intent = Intent.new(Intent.Type.MOVE)
	assert_not_null(intent, "Intent sollte erstellt werden")
	assert_eq(intent.type, Intent.Type.MOVE, "Intent Type sollte gesetzt sein")

func test_intent_types() -> void:
	var move_intent = Intent.new(Intent.Type.MOVE)
	var interact_intent = Intent.new(Intent.Type.INTERACT)
	var cancel_intent = Intent.new(Intent.Type.CANCEL)
	var load_scene_intent = Intent.new(Intent.Type.LOAD_SCENE)

	assert_eq(move_intent.type, Intent.Type.MOVE, "MOVE Type sollte korrekt sein")
	assert_eq(interact_intent.type, Intent.Type.INTERACT, "INTERACT Type sollte korrekt sein")
	assert_eq(cancel_intent.type, Intent.Type.CANCEL, "CANCEL Type sollte korrekt sein")
	assert_eq(load_scene_intent.type, Intent.Type.LOAD_SCENE, "LOAD_SCENE Type sollte korrekt sein")

func test_intent_values() -> void:
	var intent_with_value = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)
	assert_eq(intent_with_value.value, Vector2.RIGHT, "Intent Value sollte gespeichert werden")

	var intent_without_value = Intent.new(Intent.Type.INTERACT)
	assert_null(intent_without_value.value, "Intent Value sollte null sein wenn nicht gesetzt")

func test_intent_movement() -> void:
	var move_up = Intent.new(Intent.Type.MOVE, Vector2.UP)
	var move_down = Intent.new(Intent.Type.MOVE, Vector2.DOWN)
	var move_left = Intent.new(Intent.Type.MOVE, Vector2.LEFT)
	var move_right = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)

	assert_eq(move_up.value, Vector2.UP, "UP movement sollte korrekt sein")
	assert_eq(move_down.value, Vector2.DOWN, "DOWN movement sollte korrekt sein")
	assert_eq(move_left.value, Vector2.LEFT, "LEFT movement sollte korrekt sein")
	assert_eq(move_right.value, Vector2.RIGHT, "RIGHT movement sollte korrekt sein")

func test_intent_load_scene() -> void:
	var load_intent = Intent.new(Intent.Type.LOAD_SCENE, "res://src/scenes/main.tscn")
	assert_eq(load_intent.type, Intent.Type.LOAD_SCENE, "Type sollte LOAD_SCENE sein")
	assert_eq(load_intent.value, "res://src/scenes/main.tscn", "Scene path sollte gespeichert sein")
