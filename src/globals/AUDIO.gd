extends Node
class_name AUDIO
## Global Singleton für Audio-Management
## Verwaltet Musik, SFX und Audio-Einstellungen

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

var current_music: AudioStreamPlayer = null
var sfx_players: Dictionary = {}  # id -> AudioStreamPlayer

signal volume_changed(bus_name: String, volume: float)
signal music_started(track_name: String)
signal music_stopped

func _ready() -> void:
	set_name("AUDIO")
	_setup_audio_buses()
	print("✓ AUDIO Singleton initialisiert")

func _setup_audio_buses() -> void:
	# Audio-Bus-Struktur einrichten
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")

	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")

func play_music(music_path: String, fade_in: bool = false) -> void:
	if current_music:
		current_music.stop()
		current_music.queue_free()

	var music = AudioStreamPlayer.new()
	music.stream = load(music_path)
	music.bus = "Music"
	music.volume_db = linear2db(music_volume)
	add_child(music)
	music.play()
	current_music = music
	music_started.emit(music_path.get_file())

func stop_music() -> void:
	if current_music:
		current_music.stop()
		current_music.queue_free()
		current_music = null
		music_stopped.emit()

func play_sfx(sfx_path: String, sfx_id: String = "") -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load(sfx_path)
	sfx.bus = "SFX"
	sfx.volume_db = linear2db(sfx_volume)
	add_child(sfx)
	sfx.play()

	if sfx_id:
		sfx_players[sfx_id] = sfx
		sfx.finished.connect(func(): sfx_players.erase(sfx_id))

func stop_sfx(sfx_id: String) -> void:
	if sfx_players.has(sfx_id):
		sfx_players[sfx_id].stop()
		sfx_players[sfx_id].queue_free()
		sfx_players.erase(sfx_id)

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear2db(master_volume))
	volume_changed.emit("Master", master_volume)

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear2db(music_volume))
	volume_changed.emit("Music", music_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear2db(sfx_volume))
	volume_changed.emit("SFX", sfx_volume)

func mute_audio() -> void:
	AudioServer.set_bus_mute(0, true)

func unmute_audio() -> void:
	AudioServer.set_bus_mute(0, false)
