# gdlint: ignore=class-name
class_name ZeldaDoor
extends Area2D

signal player_entered_door(door: ZeldaDoor, transition_type: String)

# Direction from which the player enters the door
@export_enum("NORTH", "EAST", "SOUTH", "WEST") var entry_direction: String

# Ich mags nicht dass die türe weiss welche transitionen es gibt. Aber für jetzt ist es ok.
@export_enum("fade_to_black", "fade_to_white", "zelda") var transition_type: String
@export var push_distance: int = 16
@export var path_to_new_scene: String
@export var entry_door_name: String

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body is PlayerZelda:
        return

    player_entered_door.emit(self, transition_type)
    if transition_type == "zelda":
        SCENE_MANAGER.load_level_zelda(path_to_new_scene)
    else:
        SCENE_MANAGER.load_new_scene(path_to_new_scene, transition_type)
    queue_free()

func get_player_entry_vector() -> Vector2:
    var vector: Vector2 = Vector2.LEFT
    match entry_direction:
        0: # NORTH
            vector = Vector2.UP
        1: # EAST
            vector = Vector2.RIGHT
        2: # SOUTH
            vector = Vector2.DOWN
        3: # WEST
            vector = Vector2.LEFT
    # TODO FIX: Function does more than it should. Adjusting position here is not ideal.
    return (vector * push_distance + self.position)

func get_move_dir() -> Vector2:
    var dir: Vector2 = Vector2.ZERO
    match entry_direction:
        0: # NORTH
            dir = Vector2.DOWN
        1: # EAST
            dir = Vector2.LEFT
        2: # SOUTH
            dir = Vector2.UP
        3: # WEST
            dir = Vector2.RIGHT
    return dir