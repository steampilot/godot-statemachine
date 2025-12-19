extends Node
class_name GameStateMachineTest

## Unit Tests für GameStateMachine

var state_machine: GameStateMachine
var test_state_1: GameState
var test_state_2: GameState

func _ready() -> void:
	setup()
	print("=== GameStateMachine Tests ===")
	test_add_state()
	test_initial_state_is_null()
	test_transition_to_state()
	test_state_enter_called()
	test_state_exit_called()
	test_same_state_transition_ignored()
	test_signal_state_changed_emitted()
	test_handle_intent_to_current_state()
	print("=== Alle Tests bestanden ===\n")

func setup() -> void:
	state_machine = GameStateMachine.new()
	test_state_1 = GameState.new(GameState.Type.MAIN_MENU)
	test_state_2 = GameState.new(GameState.Type.LOADING)

func test_add_state() -> void:
	state_machine.add_state(test_state_1)
	assert(state_machine.states.has(GameState.Type.MAIN_MENU), "State sollte hinzugefügt werden")
	print("✓ test_add_state bestanden")

func test_initial_state_is_null() -> void:
	var new_sm = GameStateMachine.new()
	assert(new_sm.current_state == null, "Initial state sollte null sein")
	print("✓ test_initial_state_is_null bestanden")

func test_transition_to_state() -> void:
	state_machine.add_state(test_state_1)
	state_machine.add_state(test_state_2)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	assert(state_machine.current_state == test_state_1, "Current state sollte MAIN_MENU sein")

	state_machine.transition_to(GameState.Type.LOADING)
	assert(state_machine.current_state == test_state_2, "Current state sollte LOADING sein")
	print("✓ test_transition_to_state bestanden")

func test_state_enter_called() -> void:
	var mock_state = MockGameState.new(GameState.Type.MAIN_MENU)
	state_machine.add_state(mock_state)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	assert(mock_state.enter_called, "enter() sollte aufgerufen werden")
	print("✓ test_state_enter_called bestanden")

func test_state_exit_called() -> void:
	var mock_state_1 = MockGameState.new(GameState.Type.MAIN_MENU)
	var mock_state_2 = MockGameState.new(GameState.Type.LOADING)

	state_machine.add_state(mock_state_1)
	state_machine.add_state(mock_state_2)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	state_machine.transition_to(GameState.Type.LOADING)

	assert(mock_state_1.exit_called, "exit() sollte aufgerufen werden")
	print("✓ test_state_exit_called bestanden")

func test_same_state_transition_ignored() -> void:
	var mock_state = MockGameState.new(GameState.Type.MAIN_MENU)
	state_machine.add_state(mock_state)

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	mock_state.enter_called = false

	state_machine.transition_to(GameState.Type.MAIN_MENU)
	assert(!mock_state.enter_called, "enter() sollte nicht erneut aufgerufen werden")
	print("✓ test_same_state_transition_ignored bestanden")

func test_signal_state_changed_emitted() -> void:
	var signal_received = false
	state_machine.add_state(test_state_1)
	state_machine.add_state(test_state_2)

	state_machine.state_changed.connect(func(_old, _new): signal_received = true)
	state_machine.transition_to(GameState.Type.MAIN_MENU)

	assert(signal_received, "state_changed Signal sollte emittiert werden")
	print("✓ test_signal_state_changed_emitted bestanden")

func test_handle_intent_to_current_state() -> void:
	var mock_state = MockGameState.new(GameState.Type.MAIN_MENU)
	state_machine.add_state(mock_state)

	state_machine.transition_to(GameState.Type.MAIN_MENU)

	var intent = Intent.new(Intent.Type.MOVE, Vector2.RIGHT)
	state_machine.handle_intent(intent)

	assert(mock_state.last_intent == intent, "Intent sollte an State weitergegeben werden")
	print("✓ test_handle_intent_to_current_state bestanden")


# Mock State für Testing
class MockGameState:
	extends GameState

	var enter_called: bool = false
	var exit_called: bool = false
	var last_intent: Intent = null

	func _init(state_type: GameState.Type) -> void:
		super._init(state_type)

	func enter() -> void:
		enter_called = true

	func exit() -> void:
		exit_called = true

	func handle_intent(intent: Intent) -> void:
		last_intent = intent
