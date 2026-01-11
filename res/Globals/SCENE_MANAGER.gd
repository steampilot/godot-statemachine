extends Node
## Global Singleton für Szenen-Management
## Verwaltet Szenenwechsel und Ladebildschirme
## 2 Grundlegende Modi: Fade mit Loading Bar oder Zelda Style Slide


signal content_finished_loading(content)
signal zelda_content_finished_loading(content)
signal content_invalid(content_path: String)
signal content_failed_to_load(content_path: String)

# Height of Level (viewoprt) only used by Zelda transition
const LEVEL_H: int = 640
# Width of Level (viewport) only used by Zelda transition
const LEVEL_W: int = 480


var loading_screen
var _loading_screen_scene: PackedScene = preload("res://Globals/LOADING_SCREEN.tscn")
var _transition: String
var _content_path: String
var _load_progress_timer: Timer

# Temporary storage for level data during transitions
var _level_handoff_data: LevelDataHandoff = null

# const GAME_SCENES = {}

func _ready() -> void:
	set_name("SCENE_MANAGER")
	print("✓ SCENE_MANAGER Singleton initialisiert")

func load_new_scene(scene_path: String, transition_type: String = "fade_to_black") -> void:
	_transition = transition_type
	loading_screen = _loading_screen_scene.instantiate()
	get_tree().get_root().add_child(loading_screen)
	loading_screen.start_transition(transition_type)
	_load_content(scene_path)

func load_level_zelda(scene_path: String) -> void:
	# Zelda style does not use loading screen
	if loading_screen != null:
		await loading_screen.transition_in_complete
	_content_path = scene_path
	ResourceLoader.load_threaded_request(scene_path)
	if not ResourceLoader.exists(scene_path):
		content_invalid.emit(scene_path)
		return

	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()


func _load_content(content_path: String) -> void:
	if loading_screen != null:
		await loading_screen.transition_in_complete
	_content_path = content_path

	ResourceLoader.load_threaded_request(content_path)
	if not ResourceLoader.exists(content_path):
		content_invalid.emit(content_path)
		return
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()

func monitor_load_status() -> void:
	var load_progress := []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)
	match load_status:
		# Status 0
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			content_invalid.emit(_content_path)
			_load_progress_timer.stop()
			return
		# Status 1
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if loading_screen != null:
				loading_screen.update_bar(load_progress[0] * 100)
		# Status 2
		ResourceLoader.THREAD_LOAD_FAILED:
			content_failed_to_load.emit(_content_path)
			_load_progress_timer.stop()
			return
		# Status 3
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()


			if _transition == "zelda":
				on_zelda_content_finished_loading(
					ResourceLoader.load_threaded_get(_content_path).instantiate())
			else:
				on_content_finished_loading(
					ResourceLoader.load_threaded_get(_content_path).instantiate())


func on_content_failed_to_load(content_path: String) -> void:
	content_failed_to_load.emit(content_path)
	push_error("Resource nicht gefunden: %s" % content_path)

func on_content_invalid(content_path: String) -> void:
	content_invalid.emit(content_path)
	push_error("Resource ungültig: %s" % content_path)


func on_content_finished_loading(content: Node) -> void:
	# Find LevelContainer in the main scene
	var level_container = get_tree().current_scene.get_node_or_null("%LevelContainer")

	if not level_container:
		push_error("LevelContainer not found in current scene!")
		return

	# Get old level (if exists)
	var old_level: Node = null
	if level_container.get_child_count() > 0:
		old_level = level_container.get_child(0)

		# Extract handoff data from outgoing level
		if old_level.has_method("get") and "data" in old_level:
			_level_handoff_data = old_level.data

	# Pass handoff data to incoming level
	var incoming_level = content as ZeldaLevel
	if incoming_level and _level_handoff_data:
		incoming_level.data = _level_handoff_data
		_level_handoff_data = null

	# Remove old level
	if old_level:
		old_level.queue_free()

	# Add new level to container
	level_container.call_deferred("add_child", content)

	# Handle player teleportation
	var player = get_tree().current_scene.get_node_or_null("%PlayerZelda")
	if player and incoming_level:
		_teleport_player_to_level(player, incoming_level)

	if loading_screen != null:
		loading_screen.finish_transition()
		await loading_screen.animation_player.animation_finished
		loading_screen = null
	content_finished_loading.emit(content)

func _teleport_player_to_level(player: Node, level: ZeldaLevel) -> void:
	# Disable player during transition
	if player.has_method("disable"):
		player.disable()

	# Position player based on handoff data
	if level.data:
		for door in level.doors:
			if door.name == level.data.entry_door_name:
				player.position = door.get_player_entry_vector()
				if player.has_method("orient"):
					player.orient(level.data.move_dir)
				break

	# Re-enable player
	if player.has_method("enable"):
		player.enable()


func on_zelda_content_finished_loading(content) -> void:
	var outgoing_scene = get_tree().current_scene

	var incoming_data: LevelDataHandoff
	if get_tree().current_scene is ZeldaLevel:
		incoming_data = get_tree().current_scene.data as LevelDataHandoff

	if content is ZeldaLevel:
		content.data = incoming_data

	# slidenewlevel
	content.position.x = incoming_data.move_dir.x * LEVEL_W
	content.position.y = incoming_data.move_dir.y * LEVEL_H
	var tween_in: Tween = get_tree().create_tween()
	tween_in.tween_property(
		content, "position", Vector2.ZERO, 1.0).set_transition(
			Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# slide old level out
	var tween_out: Tween = get_tree().create_tween()
	var vector_off_screen: Vector2 = Vector2.ZERO
	vector_off_screen.x = - incoming_data.move_dir.x * LEVEL_W
	vector_off_screen.y = - incoming_data.move_dir.y * LEVEL_H
	tween_out.tween_property(
		outgoing_scene, "position", vector_off_screen, 1.0).set_transition(
			Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	get_tree().root.call_deferred("add_child", content)
	await tween_in.finished
	outgoing_scene.queue_free()

	get_tree().current_scene = content
	zelda_content_finished_loading.emit(content)
