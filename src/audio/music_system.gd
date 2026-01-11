extends Node

## Global Music System (Autoload Singleton)
## Manages multi-layer music playback using MusicAtlas tiles
## Supports Rock eJay-style music composition and dynamic layer mixing

signal atlas_loaded(atlas: MusicAtlas)
signal layer_activated(layer_name: String, tile_name: String)
signal layer_deactivated(layer_name: String)
signal all_layers_cleared

# Current active atlas
var active_atlas: MusicAtlas

# Music layers (layer_name -> MusicLayer node)
var layers: Dictionary = {}

# Standard layer names
const LAYER_DRUMS: String = "drums"
const LAYER_BASS: String = "bass"
const LAYER_GUITAR: String = "guitar"
const LAYER_VOCALS: String = "vocals"
const LAYER_SYNTH: String = "synth"
const LAYER_FX: String = "fx"

# Master volume per layer
var layer_volumes: Dictionary = {
    LAYER_DRUMS: 0.0,
    LAYER_BASS: 0.0,
    LAYER_GUITAR: 0.0,
    LAYER_VOCALS: 0.0,
    LAYER_SYNTH: 0.0,
    LAYER_FX: 0.0
}

func _ready() -> void:
    set_name("MUSIC_SYSTEM")
    _initialize_layers()
    print("✓ MUSIC_SYSTEM Singleton initialisiert")

func _initialize_layers() -> void:
    # Create standard layers
    for layer_name in [LAYER_DRUMS, LAYER_BASS, LAYER_GUITAR,
                       LAYER_VOCALS, LAYER_SYNTH, LAYER_FX]:
        var layer = MusicLayer.new()
        layer.name = layer_name
        layer.bus = "Music" # Assumes "Music" bus exists in AudioBusLayout
        layer.volume_db = layer_volumes[layer_name]
        add_child(layer)
        layers[layer_name] = layer

func load_atlas(atlas: MusicAtlas) -> void:
    active_atlas = atlas
    atlas_loaded.emit(atlas)
    print("🎵 Music Atlas loaded: %s tiles, %d BPM" % [atlas.tiles.size(), atlas.bpm])

func activate_layer(layer_name: String, tile_name: String,
                   start_on_beat: bool = true) -> void:
    if not active_atlas:
        push_error("No music atlas loaded")
        return
    
    if not layers.has(layer_name):
        push_error("Layer not found: %s" % layer_name)
        return
    
    var layer: MusicLayer = layers[layer_name]
    layer.play_tile(active_atlas, tile_name, start_on_beat)
    layer_activated.emit(layer_name, tile_name)

func deactivate_layer(layer_name: String) -> void:
    if not layers.has(layer_name):
        return
    
    var layer: MusicLayer = layers[layer_name]
    layer.stop_tile()
    layer_deactivated.emit(layer_name)

func clear_all_layers() -> void:
    for layer_name in layers.keys():
        deactivate_layer(layer_name)
    all_layers_cleared.emit()

func set_layer_volume(layer_name: String, volume_db: float) -> void:
    if not layers.has(layer_name):
        return
    
    layer_volumes[layer_name] = volume_db
    var layer: MusicLayer = layers[layer_name]
    layer.volume_db = volume_db

func fade_in_layer(layer_name: String, duration: float = 1.0) -> void:
    if not layers.has(layer_name):
        return
    
    var layer: MusicLayer = layers[layer_name]
    var tween = create_tween()
    tween.tween_property(layer, "volume_db", layer_volumes[layer_name], duration)

func fade_out_layer(layer_name: String, duration: float = 1.0,
                   stop_after_fade: bool = true) -> void:
    if not layers.has(layer_name):
        return
    
    var layer: MusicLayer = layers[layer_name]
    var tween = create_tween()
    tween.tween_property(layer, "volume_db", -80.0, duration)
    
    if stop_after_fade:
        tween.finished.connect(func(): deactivate_layer(layer_name))

func is_layer_active(layer_name: String) -> bool:
    if not layers.has(layer_name):
        return false
    return layers[layer_name].is_playing_tile

func get_active_tile(layer_name: String) -> String:
    if not layers.has(layer_name):
        return ""
    return layers[layer_name].current_tile_name

# Progression system
func unlock_tile(tile_name: String) -> void:
    if active_atlas:
        active_atlas.unlock_tile(tile_name)

func unlock_tiles(tile_names: Array[String]) -> void:
    for tile_name in tile_names:
        unlock_tile(tile_name)

func get_unlocked_tiles() -> Array[String]:
    if not active_atlas:
        return []
    return active_atlas.get_unlocked_tiles()

# Save/Load support
func get_save_data() -> Dictionary:
    var active_layers: Dictionary = {}
    for layer_name in layers.keys():
        if is_layer_active(layer_name):
            active_layers[layer_name] = get_active_tile(layer_name)
    
    return {
        "active_atlas": active_atlas.resource_path if active_atlas else "",
        "active_layers": active_layers,
        "layer_volumes": layer_volumes,
        "atlas_save_data": active_atlas.get_save_data() if active_atlas else {}
    }

func load_save_data(data: Dictionary) -> void:
    if data.has("active_atlas") and data["active_atlas"] != "":
        var atlas = load(data["active_atlas"]) as MusicAtlas
        if atlas:
            load_atlas(atlas)
            
            if data.has("atlas_save_data"):
                atlas.load_save_data(data["atlas_save_data"])
    
    if data.has("layer_volumes"):
        layer_volumes = data["layer_volumes"]
        for layer_name in layer_volumes.keys():
            set_layer_volume(layer_name, layer_volumes[layer_name])
    
    if data.has("active_layers") and active_atlas:
        for layer_name in data["active_layers"].keys():
            activate_layer(layer_name, data["active_layers"][layer_name])
