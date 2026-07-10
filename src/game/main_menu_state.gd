class_name MainMenuState
extends GameState

## State für Main Menu

func _init() -> void:
    super._init(GameState.Type.MAIN_MENU)

func enter() -> void:
    print("MainMenuState: Entered")

func exit() -> void:
    print("MainMenuState: Exited")

func handle_intent(intent: Intent) -> void:
    if intent.type == Intent.Type.LOAD_SCENE:
        print("MainMenuState: Load scene intent received - %s" % intent.value)
