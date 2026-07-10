class_name State
extends Node

@export var animation_name: String = ""

# Gravity multiplier for this state (1.0 = normal, higher = faster fall)
var gravity_multiplier: float = 1.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var parent: Player
var states: Dictionary = {} # Populated by StateMachine


func enter() -> void:
    # Validate that animation_name is set
    if animation_name == "":
        push_error("%s: animation_name is not set! Please set it in the Inspector." % get_class())
        return

    if parent and parent.sprite:
        parent.sprite.play(animation_name)

func exit() -> void:
    pass

func process_input(_event: InputEvent) -> State:
    return null

func process_frame(_delta: float) -> State:
    return null

func process_physics(_delta: float) -> State:
    return null
