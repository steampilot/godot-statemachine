extends Node

## Global Singleton für Audio-Management
## Verwaltet Musik, SFX und Audio-Einstellungen

signal volume_changed(bus_name: String, volume: float)
signal music_started(track_name: String)
signal music_stopped
signal music_track_changed(track_number: int)

const MUSIC_TRACKS = {
	1: "res://Assets/Audio/Music/Have_I_Learned_Anything/Ambient.ogg",
	2: "res://Assets/Audio/Music/Have_I_Learned_Anything/Credits.ogg",
	3: "res://Assets/Audio/Music/Have_I_Learned_Anything/DiscoAction.ogg",
}

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var dialog_volume: float = 1.0

var music_player: AudioStreamPlayer2D = null
var sfx_players: Dictionary = {} # id -> AudioStreamPlayer

# Music Track Management
var current_music_track: int = 1

func _ready() -> void:
	set_name("AUDIO")
	_setup_audio_buses()
	_setup_music_player()
	print("✓ AUDIO Singleton initialisiert")


func _setup_audio_buses() -> void:
	# Audio-Busse werden aus default_bus_layout.tres geladen
	# Prüfe ob alle erforderlichen Busse existieren
	var required_buses = ["Music", "Sounds", "Dialog"]
	for bus_name in required_buses:
		if AudioServer.get_bus_index(bus_name) == -1:
			push_warning("Audio-Bus '%s' nicht gefunden im Bus-Layout!" % bus_name)

func _setup_music_player() -> void:
	# Lade MUSIC_PLAYER Szene
	var music_player_scene = load("res://Globals/MUSIC_PLAYER.tscn")
	if music_player_scene:
		music_player = music_player_scene.instantiate()
		add_child(music_player)
		print("✓ MUSIC_PLAYER geladen")
	else:
		push_error("MUSIC_PLAYER.tscn konnte nicht geladen werden!")

func play_music(music_path: String, _fade_in: bool = false) -> void:
	if not music_player:
		push_error("MUSIC_PLAYER nicht initialisiert!")
		return
	
	# Nutze die play_track Funktion des MUSIC_PLAYER
	music_player.play_track(music_path)
	music_started.emit(music_path.get_file())

func stop_music() -> void:
	if music_player:
		music_player.stop_track()
		music_stopped.emit()

func play_sfx(sfx_path: String, sfx_id: String = "") -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load(sfx_path)
	sfx.bus = "Sounds"
	sfx.volume_db = linear_to_db(sfx_volume)
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
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	volume_changed.emit("Master", master_volume)

func get_master_volume() -> float:
	return master_volume

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))
	volume_changed.emit("Music", music_volume)

func get_music_volume() -> float:
	return music_volume

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Sounds")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))
	volume_changed.emit("Sounds", sfx_volume)

func get_sfx_volume() -> float:
	return sfx_volume

func set_dialog_volume(volume: float) -> void:
	dialog_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Dialog")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(dialog_volume))
	volume_changed.emit("Dialog", dialog_volume)

func get_dialog_volume() -> float:
	return dialog_volume

func mute_audio() -> void:
	AudioServer.set_bus_mute(0, true)

func unmute_audio() -> void:
	AudioServer.set_bus_mute(0, false)

# Music Track Management
func set_music_track(track_number: int) -> void:
	if not MUSIC_TRACKS.has(track_number):
		push_error("Ungültiger Musik-Track: %d" % track_number)
		return

	current_music_track = track_number
	var track_path = MUSIC_TRACKS[track_number]

	if FileAccess.file_exists(track_path):
		play_music(track_path)
		music_track_changed.emit(track_number)
		print("✓ Musik Track %d wird abgespielt" % track_number)
	else:
		push_warning("Musik-Datei nicht gefunden: %s" % track_path)

func get_music_track() -> int:
	return current_music_track

func get_available_tracks() -> Array:
	return MUSIC_TRACKS.keys()
