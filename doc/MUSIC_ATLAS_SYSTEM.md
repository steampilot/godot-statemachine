# Music Atlas System

## Konzept: Audio-Tilesets für Music-Driven Gameplay

Das Music Atlas System behandelt Audio-Dateien wie Sprite-Atlanten oder Godot-Tilesets: **Ein großes File mit Metadata** statt hunderte einzelner Sample-Files.

## Problem mit traditionellem Ansatz

```gdscript
# ❌ Traditionell: Viele einzelne Files
var samples = [
    "kick_01.ogg",
    "snare_01.ogg", 
    "hihat_01.ogg",
    "guitar_a.ogg",
    "bass_loop.ogg"
    # ... 100+ weitere Samples
]
# → 100+ IO-Operationen beim Laden
# → Höherer RAM-Overhead (viele kleine Buffers)
# → Komplexeres Savegame-Management
```

## Lösung: Music Atlas Pattern

### Ein File, viele "Tiles"

```gdscript
# Physisches File: level_1_music_atlas.ogg (ein großes Audio-File)
# Metadata-Ressource: level_1_music_atlas.tres

{
    "tiles": {
        "drums_kick": {"offset": 0.0, "length": 0.15},
        "drums_snare": {"offset": 0.15, "length": 0.15},
        "guitar_riff_a": {"offset": 0.3, "length": 2.0},
        "bass_loop": {"offset": 2.3, "length": 4.0},
        "vocal_yeah": {"offset": 6.3, "length": 0.5}
    },
    "bpm": 120,
    "key": "E minor"
}
```

## Architektur

### 1. MusicAtlas (Daten-Container)

Wie ein TileSet für Audio:
- Hält **eine** große AudioStream-Ressource
- Metadata definiert "Tiles" (Offset + Length)
- Kann im Editor als `.tres` Resource gespeichert werden

### 2. MusicSystem (Playback-Engine)

Verwaltet:
- Aktive Music-Layers (Drums, Bass, Guitar, Vocals)
- Welche "Tiles" aus dem Atlas gerade spielen
- Layer-Mixing und Synchronisation
- Beat-Timing für Gameplay-Events

### 3. Integration mit SCENE_MANAGER

```gdscript
# Level-Script:
@export var music_atlas: MusicAtlas = preload("res://Audio/Atlases/level_1_atlas.tres")

# SCENE_MANAGER lädt Music Atlas während des Threading-Loads
# Musik ist dann bereits im RAM wenn Level startet
```

## Vorteile

### Performance

✅ **Ein Load-Call** statt 100+  
✅ **Weniger Disk I/O** (nur ein File öffnen)  
✅ **Optimierter RAM-Usage** (ein großer Buffer statt viele kleine)  
✅ **Schnellere Level-Transitions** (alles schon geladen)  

### Gameplay

✅ **Level-gebundene Sample-Sets** (Jedes Level hat eigenen Atlas)  
✅ **Einfaches Unlock-System** ("Distortion Guitar Cassette" schaltet Tiles frei)  
✅ **Rock eJay-Style Editing** (Spieler kombiniert Tiles)  
✅ **Savegame-friendly** (nur "Atlas ID + aktive Tiles" speichern)  

### Development

✅ **Bekanntes Pattern** (wie Godot TileSets)  
✅ **Asset-Organisation** (Ein Atlas = Ein Musik-Theme)  
✅ **Editor-Tool-ready** (Atlas-Editor wie TileSet-Editor möglich)  

## Gameplay-Szenarien

### Szenario 1: Level-Progression

```gdscript
# Level startet mit minimalem Layer
music_system.activate_layer("drums", "kick_basic")

# Spieler sammelt Coin → Bass-Layer aktiviert
music_system.activate_layer("bass", "bass_loop_01")

# Boss-Room → Full Mix
music_system.activate_layer("guitar", "riff_heavy")
music_system.activate_layer("vocals", "scream_01")
```

### Szenario 2: Collectible-System

```gdscript
# Spieler findet "Distortion Guitar Cassette"
func _on_cassette_collected(cassette: Cassette):
    music_system.unlock_tiles([
        "guitar_distortion_a",
        "guitar_distortion_b",
        "guitar_distortion_solo"
    ])
    # Spieler kann jetzt diese Tiles im Home Studio verwenden
```

### Szenario 3: Home Studio (Rock eJay-Mode)

```gdscript
# Spieler baut eigenen Beat im Studio
func _on_studio_mode_active():
    music_system.clear_all_layers()
    
    # UI zeigt verfügbare Tiles aus gesammelten Atlanten
    var available_tiles = music_system.get_unlocked_tiles()
    
    # Spieler wählt Tiles aus
    studio_ui.show_tile_picker(available_tiles)
```

## Technische Implementation

### MusicAtlas Resource

```gdscript
class_name MusicAtlas
extends Resource

@export var audio_file: AudioStream
@export var tiles: Dictionary = {}
@export var bpm: int = 120
@export var musical_key: String = "C major"

func get_tile(tile_name: String) -> Dictionary:
    return tiles.get(tile_name, {})

func has_tile(tile_name: String) -> bool:
    return tiles.has(tile_name)
```

### MusicSystem Global

```gdscript
# Autoload Singleton
extends Node

var active_atlas: MusicAtlas
var layers: Dictionary = {}  # Layer-Name → AudioStreamPlayer

func load_atlas(atlas: MusicAtlas) -> void:
    active_atlas = atlas
    # Atlas ist bereits geladen durch SCENE_MANAGER

func activate_layer(layer_name: String, tile_name: String) -> void:
    if not active_atlas.has_tile(tile_name):
        return
    
    var player = layers.get_or_add(layer_name, AudioStreamPlayer.new())
    var tile = active_atlas.get_tile(tile_name)
    
    player.stream = active_atlas.audio_file
    player.play(tile.offset)
    
    # Timer für Tile-Length
    get_tree().create_timer(tile.length).timeout.connect(
        func(): player.stop()
    )
```

## Integration mit Savegame

```gdscript
# Savegame speichert nur:
{
    "current_atlas": "level_1_atlas",
    "unlocked_atlases": ["level_1_atlas", "level_2_atlas"],
    "unlocked_tiles": {
        "level_1_atlas": ["kick_01", "guitar_a", "bass_loop"],
        "level_2_atlas": ["synth_lead", "vocal_yeah"]
    },
    "studio_composition": {
        "drums": "kick_heavy",
        "bass": "bass_funk",
        "guitar": "riff_metal"
    }
}
```

## Roadmap

### Mercury Phase (Jetzt)
- Einfacher Background-Music-Player (aktuelles System ok)
- Dokumentation für spätere Implementation

### Venus Phase (Rock eJay Feature)
- MusicAtlas-System implementieren
- Layer-basiertes Playback
- Studio-Mode mit Tile-Picker
- Collectible-System (Cassettes schalten Tiles frei)

### Mars Phase (Advanced Features)
- Beat-Detection für Gameplay
- Procedural Music-Generation
- Dynamic Layer-Mixing basierend auf Gameplay-State
- Music-Editor-Tool im Godot-Editor

## Offene Fragen

1. **Looping:** Wie behandeln wir Loop-Points in Tiles?
2. **Beat-Sync:** Wie synchronisieren wir Tile-Starts auf Beat-Grid?
3. **Transitions:** Wie fade zwischen verschiedenen Atlanten?
4. **Audio-Format:** OGG Vorbis oder WAV für Atlas-Files?
5. **Compression:** Verlustfrei oder lossy für Atlas-Files?

## Verwandte Systeme

- **SCENE_MANAGER:** Lädt Atlas während Level-Loading
- **Savegame-System:** Serialisiert Musik-State
- **Collectible-System:** Cassettes schalten Atlas-Tiles frei
- **Home Studio:** Rock eJay-Mode verwendet Atlas-Tiles

## Referenzen

- Godot TileSet-System (analoges Pattern)
- Sprite Atlas/Texture Atlas (Same Konzept für Audio)
- Rock eJay / Music Maker (Gameplay-Inspiration)
- Furi / Hi-Fi Rush (Music-Driven Level-Design)
