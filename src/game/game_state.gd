class_name GameState

## Basis-State für Game State Machine

enum Type {
    MAIN_MENU,
    LOADING,
    RUNNING,
    PAUSED
}

var type: Type
var context: Dictionary = {}

func _init(t: Type, ctx: Dictionary = {}) -> void:
    type = t
    context = ctx

func enter() -> void:
    pass

func exit() -> void:
    pass

func handle_intent(intent: Intent) -> void:
    pass

func update(delta: float) -> void:
    pass
