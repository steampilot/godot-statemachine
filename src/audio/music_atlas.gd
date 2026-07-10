extends Resource
class_name MusicAtlas

## Resource that defines a Music Atlas (Audio-Tileset)
## One large audio file with metadata defining playable "tiles"
## Similar to Godot's TileSet but for audio samples

signal tile_unlocked(tile_name: String)

# The main audio file containing all samples
@export var audio_stream: AudioStream

# Tile definitions: tile_name -> {offset: float, length: float, loop: bool}
@export var tiles: Dictionary = {}

# Musical metadata
@export var bpm: int = 120
@export var time_signature: Vector2i = Vector2i(4, 4) # 4/4 time
@export var musical_key: String = "C major"

# Which tiles are unlocked (for progression system)
var unlocked_tiles: Array[String] = []

func _init() -> void:
    # By default, no tiles are unlocked (must be earned via gameplay)
    pass

func get_tile(tile_name: String) -> Dictionary:
    if not tiles.has(tile_name):
        push_error("Tile not found in atlas: %s" % tile_name)
        return {}
    return tiles[tile_name]

func has_tile(tile_name: String) -> bool:
    return tiles.has(tile_name)

func is_tile_unlocked(tile_name: String) -> bool:
    return tile_name in unlocked_tiles

func unlock_tile(tile_name: String) -> void:
    if not has_tile(tile_name):
        push_error("Cannot unlock tile that doesn't exist: %s" % tile_name)
        return

    if tile_name in unlocked_tiles:
        return

    unlocked_tiles.append(tile_name)
    tile_unlocked.emit(tile_name)
    print("🎵 Unlocked music tile: %s" % tile_name)

func unlock_all_tiles() -> void:
    for tile_name in tiles.keys():
        unlock_tile(tile_name)

func get_unlocked_tiles() -> Array[String]:
    return unlocked_tiles.duplicate()

func get_all_tile_names() -> Array[String]:
    var names: Array[String] = []
    names.assign(tiles.keys())
    return names

func get_beat_length() -> float:
    # Returns length of one beat in seconds
    return 60.0 / float(bpm)

func get_bar_length() -> float:
    # Returns length of one bar in seconds
    return get_beat_length() * float(time_signature.x)

# Save/Load support
func get_save_data() -> Dictionary:
    return {
        "unlocked_tiles": unlocked_tiles,
        "bpm": bpm,
        "musical_key": musical_key
    }

func load_save_data(data: Dictionary) -> void:
    if data.has("unlocked_tiles"):
        unlocked_tiles = data["unlocked_tiles"]
    if data.has("bpm"):
        bpm = data["bpm"]
    if data.has("musical_key"):
        musical_key = data["musical_key"]
