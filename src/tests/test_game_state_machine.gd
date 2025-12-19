extends GutTest

## Unit Tests für GameStateMachine mit GUT

var state_machine: GameStateMachine
var test_state_1: GameState
var test_state_2: GameState

func before_each() -> void:
	state_machine = GameStateMachine.new()
	test_state_1 = GameState.new(GameState.Type.MAIN_MENU)
	test_state_2 = GameState.new(GameState.Type.LOADING)

func test_add_state() -> void:
	state_machine.add_state(test_state_1)
	assert_true(state_machine.states.has(GameState.Type.MAIN_MENU), "State sollte hinzugefügt werden")

func test_initial_state_is_null() -> void:
	var new_sm = GameStateMachine.new()
	assert_null(new_sm.current_state, "Initial state sollte null sein")

func test_transition_to_state() -> void:
	state_machine.add_state(test_state_1)
	state_machine.add_state(test_state_2)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	assert_eq(state_machine.current_state, test_state_1, "Current state sollte MAIN_MENU sein")

	state_machine.transition_to(GameState.Type.LOADING)
	assert_eq(state_machine.current_state, test_state_2, "Current state sollte LOADING sein")

func test_state_enter_called() -> void:
	class MockGameState:
		extends GameState
		var enter_called: bool = false

		func _init(state_type: GameState.Type) -> void:
			super._init(state_type)

		func enter() -> void:
			enter_called = true

	var mock_state = MockGameState.new(GameState.Type.MAIN_MENU)
	state_machine.add_state(mock_state)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	assert_true(mock_state.enter_called, "enter() sollte aufgerufen werden")

func test_state_exit_called() -> void:
	class MockGameState:
		extends GameState
		var exit_called: bool = false

		func _init(state_type: GameState.Type) -> void:
			super._init(state_type)

		func exit() -> void:
			exit_called = true

	var mock_state_1 = MockGameState.new(GameState.Type.MAIN_MENU)
	var mock_state_2 = MockGameState.new(GameState.Type.LOADING)

	state_machine.add_state(mock_state_1)
	state_machine.add_state(mock_state_2)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	state_machine.transition_to(GameState.Type.LOADING)

	assert_true(mock_state_1.exit_called, "exit() sollte aufgerufen werden")

func test_same_state_transition_ignored() -> void:
	class MockGameState:
		extends GameState
		var enter_count: int = 0

		func _init(state_type: GameState.Type) -> void:
			super._init(state_type)

		func enter() -> void:
			enter_count += 1

	var mock_state = MockGameState.new(GameState.Type.MAIN_MENU)
	state_machine.add_state(mock_state)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	var first_count = mock_state.enter_count

	state_machine.transition_to(GameState.Type.MAIN_MENU)

	assert_eq(mock_state.enter_count, first_count, "enter() sollte nicht erneut aufgerufen werden")

func test_signal_state_changed_emitted() -> void:
	var signal_received = false
	state_machine.add_state(test_state_1)

	state_machine.state_changed.connect(func(_old, _new): signal_received = true)
	state_machine.transition_to(GameState.Type.MAIN_MENU)

	assert_true(signal_received, "state_changed Signal sollte emittiert werden")

func test_handle_intent_to_current_state() -> void:
	class MockGameState:
		extends GameState
		var last_intent: Intent = null

		func _init(state_type: GameState.Type) -> void:
			super._init(state_type)

		func handle_intent(intent: Intent) -> void:
			last_intent = intent

	var mock_state = MockGameState.new(GameState.Type.MAIN_MENU)
	state_machine.add_state(mock_state)

	state_machine.transition_to(GameState.Type.MAIN_MENU)

	var intent = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)
	state_machine.handle_intent(intent)

	assert_eq(mock_state.last_intent, intent, "Intent sollte an State weitergegeben werden")
