class_name GameStateMachine
extends Node

## State Machine für Game-Level States

signal state_changed(old_state: GameState, new_state: GameState)

var current_state: GameState
var states: Dictionary = {}

func _ready() -> void:
    pass

func add_state(state: GameState) -> void:
    states[state.type] = state
    add_child(state)

func transition_to(state_type: GameState.Type, context: Dictionary = {}) -> void:
    if current_state and current_state.type == state_type:
        return

    if current_state:
        current_state.exit()
        state_changed.emit(current_state, null)

    current_state = states.get(state_type)
    if not current_state:
        push_error("State nicht gefunden: %s" % state_type)
        return

    current_state.context = context
    current_state.enter()
    state_changed.emit(null, current_state)

func handle_intent(intent: Intent) -> void:
    if current_state:
        current_state.handle_intent(intent)

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)
