extends AudioStreamPlayer
class_name MusicLayer

## Represents one layer in the music system (e.g., drums, bass, guitar)
## Plays tiles from a MusicAtlas with proper timing and looping

signal layer_started(tile_name: String)
signal layer_stopped
signal beat_hit(beat_number: int)

var current_tile_name: String = ""
var is_playing_tile: bool = false
var _current_atlas: MusicAtlas
var _beat_timer: Timer
var _stop_timer: Timer
var _current_beat: int = 0

func _ready() -> void:
    finished.connect(_on_playback_finished)

    _beat_timer = Timer.new()
    _beat_timer.one_shot = false
    add_child(_beat_timer)
    _beat_timer.timeout.connect(_on_beat)

    _stop_timer = Timer.new()
    _stop_timer.one_shot = true
    add_child(_stop_timer)
    _stop_timer.timeout.connect(_on_tile_length_reached)

func play_tile(atlas: MusicAtlas, tile_name: String, start_on_beat: bool = false) -> void:
    if not atlas.has_tile(tile_name):
        push_error("Tile not found: %s" % tile_name)
        return

    if not atlas.is_tile_unlocked(tile_name):
        push_error("Tile not unlocked: %s" % tile_name)
        return

    _current_atlas = atlas
    current_tile_name = tile_name

    var tile = atlas.get_tile(tile_name)
    stream = atlas.audio_stream

    if start_on_beat:
        # TODO: Wait for next beat to start playback
        # For now, just play immediately
        pass

    play(tile.offset)
    is_playing_tile = true

    # Setup beat timer
    _beat_timer.wait_time = atlas.get_beat_length()
    _beat_timer.start()
    _current_beat = 0

    # Setup stop timer if tile doesn't loop
    if not tile.get("loop", false):
        _stop_timer.wait_time = tile.length
        _stop_timer.start()

    layer_started.emit(tile_name)
    print("🎵 Layer playing tile: %s" % tile_name)

func stop_tile() -> void:
    if is_playing_tile:
        stop()
        is_playing_tile = false
        current_tile_name = ""
        _beat_timer.stop()
        _stop_timer.stop()
        layer_stopped.emit()

func _on_beat() -> void:
    _current_beat += 1
    beat_hit.emit(_current_beat)

func _on_tile_length_reached() -> void:
    # Tile finished playing (non-looping tile)
    stop_tile()

func _on_playback_finished() -> void:
    # AudioStreamPlayer finished playing
    if is_playing_tile:
        var tile = _current_atlas.get_tile(current_tile_name)
        if tile.get("loop", false):
            # Restart looping tile
            play(tile.offset)
        else:
            stop_tile()
