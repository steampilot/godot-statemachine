class_name StateMachine

extends Node

@export var starting_state_name: String = "idle"

var current_state: State = null
var states: Dictionary = {}

# Initialize the state machine by giving each child state
# a reference to the parent object it belongs to
# Build a dictionary of all available states and share it
func init(parent: Player) -> void:
	# First pass: collect all states
	for child in get_children():
		if child is State:
			# Use node name as key (convert to lowercase for consistency)
			var state_name = child.name.to_lower().replace("state", "")
			states[state_name] = child

	# Second pass: initialize states with parent and states dict
	for child in get_children():
		if child is State:
			child.parent = parent
			child.states = states

	# Start with the initial state
	if states.has(starting_state_name):
		change_state(states[starting_state_name])
	else:
		push_error("Starting state '%s' not found in StateMachine!" % starting_state_name)

# change to a new state by first calling any exit logic on the current state
# then setting the current_state to the new state and calling its enter logic
func change_state(new_state: State) -> void:
	if not new_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

 # Pass through functions for the player to call on the current state
 # handling state changes as needed

func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
