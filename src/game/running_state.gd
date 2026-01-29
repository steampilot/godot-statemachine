class_name RunningState
extends GameState

## State für laufendes Spiel

func _init() -> void:
    super._init(GameState.Type.RUNNING)

func enter() -> void:
    print("RunningState: Game running")

func exit() -> void:
    print("RunningState: Exited")

func handle_intent(intent: Intent) -> void:
    if intent.type == Intent.Type.PAUSE:
        print("RunningState: Pause intent received")
