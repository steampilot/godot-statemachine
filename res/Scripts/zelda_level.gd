class_name ZeldaLevel
extends Node2D

## Level geometry container - does NOT manage player!
## Player is persistent in parent scene (zelda_main)

@export var doors: Array[ZeldaDoor] = []
var data: LevelDataHandoff = null

func _ready() -> void:
    _connect_to_doors()

    if data == null:
        print("ℹ️ Level started directly (no transition data)")

func _connect_to_doors() -> void:
    for door in doors:
        if not door.player_entered_door.is_connected(_on_player_entered_door):
            door.player_entered_door.connect(_on_player_entered_door)

func _disconnect_from_doors() -> void:
    for door in doors:
        if door.player_entered_door.is_connected(_on_player_entered_door):
            door.player_entered_door.disconnect(_on_player_entered_door)

func _on_player_entered_door(door: ZeldaDoor) -> void:
    _disconnect_from_doors()

    # Create handoff data for next level
    data = LevelDataHandoff.new()
    data.entry_door_name = door.entry_door_name
    data.move_dir = door.get_move_dir()
