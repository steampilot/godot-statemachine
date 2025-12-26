class_name State
extends Node

@export var animation_name: String = ""

@export var move_speed: float = 400

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var parent: Player
var states: Dictionary = {} # Populated by StateMachine


func enter() -> void:
	if animation_name != "" and parent and parent.sprite:
		parent.sprite.play(animation_name)

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
