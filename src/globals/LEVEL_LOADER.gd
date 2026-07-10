extends Node
class_name LEVEL_LOADER
## Global Singleton für Level- und Szenen-Verwaltung

var current_level: int = 1
var loaded_scene: Node = null
var level_scenes: Dictionary = {
    1: "res://src/scenes/main.tscn",
    2: "res://src/scenes/main.tscn",  # Placeholder
    3: "res://src/scenes/main.tscn",  # Placeholder
}

signal level_loaded(level: int, scene_name: String)
signal level_unloaded(level: int)

func _ready() -> void:
    set_name("LEVEL_LOADER")
    print("✓ LEVEL_LOADER Singleton initialisiert")

func load_level(level_num: int) -> void:
    if not level_scenes.has(level_num):
        push_error("Level %d nicht definiert" % level_num)
        return

    current_level = level_num
    var scene_path = level_scenes[level_num]

    # Alte Szene entfernen
    if loaded_scene:
        loaded_scene.queue_free()
        level_unloaded.emit(level_num - 1)

    # Neue Szene laden
    var scene = load(scene_path)
    if scene:
        loaded_scene = scene.instantiate()
        get_tree().root.add_child(loaded_scene)
        var scene_name = scene_path.get_file().trim_suffix(".tscn")
        level_loaded.emit(level_num, scene_name)
    else:
        push_error("Szene nicht gefunden: %s" % scene_path)

func next_level() -> void:
    load_level(current_level + 1)

func previous_level() -> void:
    if current_level > 1:
        load_level(current_level - 1)

func restart_level() -> void:
    load_level(current_level)

func add_level(level_num: int, scene_path: String) -> void:
    level_scenes[level_num] = scene_path

func get_current_level() -> int:
    return current_level

func get_level_scene(level_num: int) -> String:
    return level_scenes.get(level_num, "")
