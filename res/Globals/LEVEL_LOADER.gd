extends Node

## Global Singleton für Level- und Szenen-Verwaltung
## Verwaltet das Laden und Entladen von Level-Szenen

signal level_load_started(scene_path: String)
signal level_loaded(scene_path: String)
signal level_unloaded(scene_path: String)

var current_level_scene: Node = null
var current_level_path: String = ""

func _ready() -> void:
	set_name("LEVEL_LOADER")
	print("✓ LEVEL_LOADER Singleton initialisiert")

## Lädt eine Level-Szene per Pfad
func load_level(scene_path: String) -> void:
	if not FileAccess.file_exists(scene_path):
		push_error("Level-Szene nicht gefunden: %s" % scene_path)
		return
	
	level_load_started.emit(scene_path)
	print("→ Lade Level: %s" % scene_path)
	
	# Alte Level-Szene entladen
	if current_level_scene:
		unload_current_level()
	
	# Neue Szene laden
	var error = get_tree().change_scene_to_file(scene_path)
	if error == OK:
		current_level_path = scene_path
		level_loaded.emit(scene_path)
		print("✓ Level geladen: %s" % scene_path.get_file())
	else:
		push_error("Fehler beim Laden der Szene: %s" % scene_path)

## Lädt eine Level-Szene per PackedScene
func load_level_packed(scene: PackedScene) -> void:
	if not scene:
		push_error("PackedScene ist null!")
		return
	
	var scene_path = scene.resource_path
	level_load_started.emit(scene_path)
	print("→ Lade Level: %s" % scene_path)
	
	# Alte Level-Szene entladen
	if current_level_scene:
		unload_current_level()
	
	# Neue Szene laden
	var error = get_tree().change_scene_to_packed(scene)
	if error == OK:
		current_level_path = scene_path
		level_loaded.emit(scene_path)
		print("✓ Level geladen: %s" % scene_path.get_file())
	else:
		push_error("Fehler beim Laden der PackedScene: %s" % scene_path)

## Entlädt das aktuelle Level
func unload_current_level() -> void:
	if current_level_scene:
		var old_path = current_level_path
		current_level_scene.queue_free()
		current_level_scene = null
		current_level_path = ""
		level_unloaded.emit(old_path)
		print("✓ Level entladen: %s" % old_path.get_file())

## Gibt den aktuellen Level-Pfad zurück
func get_current_level_path() -> String:
	return current_level_path

## Lädt das aktuelle Level neu
func reload_current_level() -> void:
	if current_level_path.is_empty():
		push_warning("Kein Level zum Neuladen vorhanden")
		return
	
	var path = current_level_path
	load_level(path)
