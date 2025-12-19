extends Node
class_name SceneLoader

## Verwaltet Laden und Wechsel von Szenen

signal scene_loaded(scene_name: String)
signal scene_unloaded(scene_name: String)

var current_scene: Node
var loading: bool = false

func _ready() -> void:
	pass

func load_scene(scene_path: String) -> void:
	if loading:
		push_warning("Szene wird bereits geladen: %s" % scene_path)
		return

	loading = true

	# Alte Szene entfernen
	if current_scene:
		var old_name = current_scene.name
		current_scene.queue_free()
		scene_unloaded.emit(old_name)

	# Neue Szene laden
	var scene = load(scene_path)
	if not scene:
		push_error("Szene nicht gefunden: %s" % scene_path)
		loading = false
		return

	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)

	var scene_name = scene_path.get_file().trim_suffix(".tscn")
	scene_loaded.emit(scene_name)
	loading = false

func unload_scene() -> void:
	if current_scene:
		var scene_name = current_scene.name
		current_scene.queue_free()
		current_scene = null
		scene_unloaded.emit(scene_name)
