extends Node

## Adaptiver Musik-Player mit mehreren synchronisierten Layern
## Erlaubt dynamisches Ein-/Ausblenden von Instrumenten basierend auf Level-Progress

signal track_started(track_name: String)
signal track_finished
signal layer_changed(layer_index: int, enabled: bool)

# Music Layer System
# Jeder Layer ist ein AudioStreamPlayer mit eigenem Stream und Volume
var layers: Array[AudioStreamPlayer] = []
var layer_volumes: Array[float] = []
var layer_target_volumes: Array[float] = []
var is_playing: bool = false

# Fade Settings
# Wie schnell Layer ein/ausgeblendet werden (in dB pro Sekunde)
var fade_speed: float = 10.0

func _ready() -> void:
	# Erstelle Layer-Container
	pass

func setup_layers(track_paths: Array[String]) -> void:
	"""
	Richtet mehrere Audio-Layer ein, die synchron abgespielt werden.
	track_paths: Array von Pfaden zu den einzelnen Audio-Streams (Layer)
	"""
	# Cleanup alte Layer
	clear_layers()
	
	# Erstelle für jeden Track einen AudioStreamPlayer
	for i in range(track_paths.size()):
		var audio_stream = load(track_paths[i])
		if not audio_stream:
			push_error("Konnte Layer %d nicht laden: %s" % [i, track_paths[i]])
			continue
		
		var player = AudioStreamPlayer.new()
		player.stream = audio_stream
		player.bus = "Music"
		player.volume_db = -80.0
		add_child(player)
		
		layers.append(player)
		layer_volumes.append(-80.0)
		layer_target_volumes.append(-80.0)
		
		print("♪ Layer %d geladen: %s" % [i, track_paths[i].get_file()])

func play_track(track_path: String) -> void:
	"""
	Legacy-Funktion für einzelne Tracks (ohne Layer-System)
	"""
	setup_layers([track_path])
	play_all_layers()
	set_layer_enabled(0, true)

func play_all_layers() -> void:
	"""
	Startet alle Layer synchron
	"""
	if layers.is_empty():
		push_error("Keine Layer geladen!")
		return
	
	is_playing = true
	
	# Starte alle Layer gleichzeitig
	for player in layers:
		player.play()
	
	track_started.emit("Layered Music")
	print("♪ Layered Music gestartet (%d Layer)" % layers.size())

func stop_all_layers() -> void:
	"""
	Stoppt alle Layer
	"""
	is_playing = false
	
	for player in layers:
		player.stop()
	
	track_finished.emit()

func set_layer_enabled(layer_index: int, enabled: bool, fade: bool = true) -> void:
	"""
	Aktiviert/Deaktiviert einen Layer
	layer_index: Index des Layers (0-basiert)
	enabled: true = Layer hörbar, false = Layer stumm
	fade: true = sanftes Ein/Ausblenden, false = sofort
	"""
	if layer_index < 0 or layer_index >= layers.size():
		push_error("Ungültiger Layer-Index: %d" % layer_index)
		return
	
	var target_volume = 0.0 if enabled else -80.0
	layer_target_volumes[layer_index] = target_volume
	
	if not fade:
		layer_volumes[layer_index] = target_volume
		layers[layer_index].volume_db = target_volume
	
	layer_changed.emit(layer_index, enabled)
	print("♪ Layer %d %s" % [layer_index, "aktiviert" if enabled else "deaktiviert"])

func set_layer_volume(layer_index: int, volume_db: float) -> void:
	"""
	Setzt die Lautstärke eines Layers direkt
	"""
	if layer_index < 0 or layer_index >= layers.size():
		push_error("Ungültiger Layer-Index: %d" % layer_index)
		return
	
	layer_target_volumes[layer_index] = volume_db
	layer_volumes[layer_index] = volume_db
	layers[layer_index].volume_db = volume_db

func stop_track() -> void:
	"""
	Legacy-Funktion
	"""
	stop_all_layers()

func is_playing_track() -> bool:
	return is_playing

func clear_layers() -> void:
	"""
	Entfernt alle Layer
	"""
	for player in layers:
		if player:
			player.queue_free()
	
	layers.clear()
	layer_volumes.clear()
	layer_target_volumes.clear()
	is_playing = false

func _process(delta: float) -> void:
	# Fade Layer Volumes zu ihren Target-Werten
	for i in range(layers.size()):
		if layer_volumes[i] != layer_target_volumes[i]:
			var direction = 1.0 if layer_target_volumes[i] > layer_volumes[i] else -1.0
			layer_volumes[i] += direction * fade_speed * delta
			
			# Clamp zum Target
			if direction > 0:
				layer_volumes[i] = min(layer_volumes[i], layer_target_volumes[i])
			else:
				layer_volumes[i] = max(layer_volumes[i], layer_target_volumes[i])
			
			layers[i].volume_db = layer_volumes[i]
