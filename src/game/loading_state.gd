class_name LoadingState
extends GameState

## State für Szenen-Laden

var scene_loader: SceneLoader

func _init(loader: SceneLoader) -> void:
	super._init(GameState.Type.LOADING)
	scene_loader = loader

func enter() -> void:
	var target_scene = context.get("target_scene", "")
	print("LoadingState: Loading %s" % target_scene)

func exit() -> void:
	print("LoadingState: Exited")

func handle_intent(intent: Intent) -> void:
	pass
