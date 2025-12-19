extends Node
class_name SceneLoaderTest

## Unit Tests für SceneLoader

var scene_loader: SceneLoader
var test_scene_path: String = "res://src/scenes/main_menu.tscn"

func _ready() -> void:
	setup()
	print("=== SceneLoader Tests ===")
	test_initial_state()
	test_load_scene_sets_flag()
	test_load_scene_signals()
	test_unload_scene_signals()
	test_invalid_scene_path()
	print("=== Alle Tests bestanden ===\n")

func setup() -> void:
	scene_loader = SceneLoader.new()

func test_initial_state() -> void:
	assert(scene_loader.current_scene == null, "Initial scene sollte null sein")
	assert(scene_loader.loading == false, "loading sollte anfangs false sein")
	print("✓ test_initial_state bestanden")

func test_load_scene_sets_flag() -> void:
	scene_loader.loading = false
	scene_loader.load_scene(test_scene_path)

	# Nach dem Load sollte loading false sein (asynchron abgeschlossen)
	assert(scene_loader.loading == false, "loading sollte nach Load false sein")
	print("✓ test_load_scene_sets_flag bestanden")

func test_load_scene_signals() -> void:
	var signal_received = false
	var received_name = ""

	scene_loader.scene_loaded.connect(func(name: String):
		signal_received = true
		received_name = name
	)

	scene_loader.load_scene(test_scene_path)

	assert(signal_received, "scene_loaded Signal sollte emittiert werden")
	assert(received_name == "main_menu", "Scene name sollte 'main_menu' sein")
	print("✓ test_load_scene_signals bestanden")

func test_unload_scene_signals() -> void:
	var unload_signal_received = false
	var unload_name = ""

	scene_loader.scene_unloaded.connect(func(name: String):
		unload_signal_received = true
		unload_name = name
	)

	# Erst laden, dann entladen
	scene_loader.load_scene(test_scene_path)
	scene_loader.unload_scene()

	assert(unload_signal_received, "scene_unloaded Signal sollte emittiert werden")
	assert(scene_loader.current_scene == null, "current_scene sollte null nach unload sein")
	print("✓ test_unload_scene_signals bestanden")

func test_invalid_scene_path() -> void:
	var invalid_path = "res://nonexistent/path.tscn"
	scene_loader.load_scene(invalid_path)

	assert(scene_loader.loading == false, "loading sollte false sein nach fehler")
	print("✓ test_invalid_scene_path bestanden")
