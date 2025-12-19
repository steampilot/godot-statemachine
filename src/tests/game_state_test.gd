extends Node
class_name GameStateTest

## Unit Tests für GameState

func _ready() -> void:
	print("=== GameState Tests ===")
	test_state_creation()
	test_state_context()
	test_state_type()
	test_state_callbacks()
	print("=== Alle Tests bestanden ===\n")

func test_state_creation() -> void:
	var state = GameState.new(GameState.Type.MAIN_MENU)
	assert(state != null, "State sollte erstellt werden")
	assert(state.type == GameState.Type.MAIN_MENU, "State Type sollte gesetzt sein")
	print("✓ test_state_creation bestanden")

func test_state_context() -> void:
	var context = {"scene": "main.tscn", "level": 1}
	var state = GameState.new(GameState.Type.RUNNING, context)

	assert(state.context == context, "Context sollte gespeichert werden")
	assert(state.context.get("scene") == "main.tscn", "Context werte sollten zugänglich sein")
	print("✓ test_state_context bestanden")

func test_state_type() -> void:
	var state_1 = GameState.new(GameState.Type.MAIN_MENU)
	var state_2 = GameState.new(GameState.Type.LOADING)
	var state_3 = GameState.new(GameState.Type.RUNNING)

	assert(state_1.type == GameState.Type.MAIN_MENU, "Type MAIN_MENU sollte korrekt sein")
	assert(state_2.type == GameState.Type.LOADING, "Type LOADING sollte korrekt sein")
	assert(state_3.type == GameState.Type.RUNNING, "Type RUNNING sollte korrekt sein")
	print("✓ test_state_type bestanden")

func test_state_callbacks() -> void:
	var enter_called = false
	var exit_called = false
	var intent_handled = false
	var update_called = false

	class TestState:
		extends GameState
		var enter_called: bool = false
		var exit_called: bool = false
		var intent_handled: bool = false
		var update_called: bool = false

		func _init() -> void:
			super._init(GameState.Type.RUNNING)

		func enter() -> void:
			enter_called = true

		func exit() -> void:
			exit_called = true

		func handle_intent(_intent: Intent) -> void:
			intent_handled = true

		func update(_delta: float) -> void:
			update_called = true

	var test_state = TestState.new()
	test_state.enter()
	test_state.exit()
	test_state.handle_intent(Intent.new(Intent.Type.MOVE))
	test_state.update(0.016)

	assert(test_state.enter_called, "enter() sollte aufgerufen werden")
	assert(test_state.exit_called, "exit() sollte aufgerufen werden")
	assert(test_state.intent_handled, "handle_intent() sollte aufgerufen werden")
	assert(test_state.update_called, "update() sollte aufgerufen werden")
	print("✓ test_state_callbacks bestanden")
