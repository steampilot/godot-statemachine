extends Node
class_name GameController

## Orchestriert Game State Machine und Scene Loader

var state_machine: GameStateMachine
var scene_loader: SceneLoader
var intent_emitter: IntentEmitter
var main_menu: MainMenu

var main_menu_state: MainMenuState
var loading_state: LoadingState
var running_state: RunningState

signal scene_loaded(scene_name: String)

func _ready() -> void:
	# Child-Nodes erstellen
	state_machine = GameStateMachine.new()
	scene_loader = SceneLoader.new()
	intent_emitter = IntentEmitter.new()

	add_child(state_machine)
	add_child(scene_loader)
	add_child(intent_emitter)

	# States erstellen und registrieren
	main_menu_state = MainMenuState.new()
	loading_state = LoadingState.new(scene_loader)
	running_state = RunningState.new()

	state_machine.add_state(main_menu_state)
	state_machine.add_state(loading_state)
	state_machine.add_state(running_state)

	# Main Menu UI erstellen und anzeigen
	var main_menu_scene = load("res://src/scenes/main_menu.tscn")
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	main_menu.load_scene_requested.connect(_on_load_scene_requested)

	# Zu Main Menu starten
	state_machine.transition_to(GameState.Type.MAIN_MENU)

	# Signal-Verbindungen
	scene_loader.scene_loaded.connect(_on_scene_loaded)

func _process(_delta: float) -> void:
	var intents = intent_emitter.collect()
	for intent in intents:
		state_machine.handle_intent(intent)

func _on_load_scene_requested(scene_path: String) -> void:
	# Main Menu verstecken
	main_menu.hide()

	# Szene laden
	state_machine.transition_to(GameState.Type.LOADING, {"target_scene": scene_path})
	scene_loader.load_scene(scene_path)

func _on_scene_loaded(scene_name: String) -> void:
	scene_loaded.emit(scene_name)
	state_machine.transition_to(GameState.Type.RUNNING)

