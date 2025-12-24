extends AudioStreamPlayer

## Dedizierter Musik-Player für das Audio-System
## Wird von AUDIO.gd angesteuert

signal track_started(track_name: String)
signal track_finished

func play_track(track_path: String) -> void:
	var audio_stream = load(track_path)
	if audio_stream:
		stream = audio_stream
		play()
		track_started.emit(track_path.get_file())
		print("♪ Spiele Musik: %s" % track_path.get_file())
	else:
		push_error("Konnte Track nicht laden: %s" % track_path)

func stop_track() -> void:
	if playing:
		stop()
		track_finished.emit()

func is_playing_track() -> bool:
	return playing

func _ready() -> void:
	finished.connect(_on_track_finished)

func _on_track_finished() -> void:
	track_finished.emit()
