extends GutTest

## Unit Tests für GameState mit GUT

func test_state_creation() -> void:
	var state = GameState.new(GameState.Type.MAIN_MENU)
	assert_not_null(state, "State sollte erstellt werden")
	assert_eq(state.type, GameState.Type.MAIN_MENU, "State Type sollte gesetzt sein")

func test_state_context() -> void:
	var context = {"scene": "main.tscn", "level": 1}
	var state = GameState.new(GameState.Type.RUNNING, context)

	assert_eq(state.context, context, "Context sollte gespeichert werden")
	assert_eq(state.context.get("scene"), "main.tscn", "Context Werte sollten zugänglich sein")

func test_state_type() -> void:
	var state_1 = GameState.new(GameState.Type.MAIN_MENU)
	var state_2 = GameState.new(GameState.Type.LOADING)
	var state_3 = GameState.new(GameState.Type.RUNNING)

	assert_eq(state_1.type, GameState.Type.MAIN_MENU, "Type MAIN_MENU sollte korrekt sein")
	assert_eq(state_2.type, GameState.Type.LOADING, "Type LOADING sollte korrekt sein")
	assert_eq(state_3.type, GameState.Type.RUNNING, "Type RUNNING sollte korrekt sein")

func test_state_enter_exit_callbacks() -> void:
	var enter_called = false
	var exit_called = false

	class TestState:
		extends GameState
		var test_enter_called: bool = false
		var test_exit_called: bool = false

		func _init() -> void:
			super._init(GameState.Type.RUNNING)

		func enter() -> void:
			test_enter_called = true

		func exit() -> void:
			test_exit_called = true

	var test_state = TestState.new()
	test_state.enter()
	test_state.exit()

	assert_true(test_state.test_enter_called, "enter() sollte aufgerufen werden")
	assert_true(test_state.test_exit_called, "exit() sollte aufgerufen werden")

func test_state_handle_intent() -> void:
	var intent_received = false
	var received_intent = null

	class TestState:
		extends GameState
		var test_intent_received: bool = false
		var test_received_intent: Intent = null

		func _init() -> void:
			super._init(GameState.Type.RUNNING)

		func handle_intent(intent: Intent) -> void:
			test_intent_received = true
			test_received_intent = intent

	var test_state = TestState.new()
	var test_intent = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)
	test_state.handle_intent(test_intent)

	assert_true(test_state.test_intent_received, "handle_intent() sollte aufgerufen werden")
	assert_eq(test_state.test_received_intent, test_intent, "Intent sollte weitergegeben werden")
