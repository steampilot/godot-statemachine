extends GutTest

## Unit Tests für SceneLoader mit GUT

var scene_loader: SceneLoader
var test_scene_path: String = "res://src/scenes/main_menu.tscn"

func before_each() -> void:
	scene_loader = SceneLoader.new()

func test_initial_state() -> void:
	assert_null(scene_loader.current_scene, "Initial scene sollte null sein")
	assert_false(scene_loader.loading, "loading sollte anfangs false sein")

func test_load_scene_sets_loading_flag() -> void:
	scene_loader.load_scene(test_scene_path)
	assert_false(scene_loader.loading, "loading sollte nach Load false sein")

func test_load_scene_signals() -> void:
	var signal_received = false
	var received_name = ""

	scene_loader.scene_loaded.connect(func(name: String):
		signal_received = true
		received_name = name
	)

	scene_loader.load_scene(test_scene_path)

	assert_true(signal_received, "scene_loaded Signal sollte emittiert werden")
	assert_eq(received_name, "main_menu", "Scene name sollte 'main_menu' sein")

func test_unload_scene_signals() -> void:
	var unload_signal_received = false
	var unload_name = ""

	scene_loader.scene_unloaded.connect(func(name: String):
		unload_signal_received = true
		unload_name = name
	)

	scene_loader.load_scene(test_scene_path)
	scene_loader.unload_scene()

	assert_true(unload_signal_received, "scene_unloaded Signal sollte emittiert werden")
	assert_null(scene_loader.current_scene, "current_scene sollte null nach unload sein")

func test_invalid_scene_path() -> void:
	var invalid_path = "res://nonexistent/path.tscn"
	scene_loader.load_scene(invalid_path)

	assert_false(scene_loader.loading, "loading sollte false sein nach Fehler")

func test_loading_flag_prevents_concurrent_loads() -> void:
	scene_loader.loading = true

	# Sollte frühzeitig zurückkehren
	scene_loader.load_scene(test_scene_path)

	assert_true(scene_loader.loading, "loading sollte noch true sein")
