# Audio System Architecture (SRC Template)

**Status:** Template/Reference Implementation  
**Location:** `src/audio/` (NOT active in RES yet)

## Overview

This directory contains the **template implementation** for the Music Atlas System, designed for future integration when Rock eJay-style music gameplay is needed.

## Components

### Core Classes

- **`music_atlas.gd`** - Resource defining audio-tilesets (one file + metadata)
- **`music_layer.gd`** - AudioStreamPlayer that plays tiles from an atlas
- **`music_system.gd`** - Global singleton managing multi-layer music playback

### Documentation

- **`../../doc/MUSIC_ATLAS_SYSTEM.md`** - Full architecture documentation

## Current Status

### Mercury Phase (Now)
✅ Documentation complete  
✅ Template code in SRC  
❌ NOT integrated into RES (using simple MUSIC_PLAYER for now)

### Venus Phase (Rock eJay Feature)
- Migrate templates from SRC → RES
- Implement MusicAtlas resources for levels
- Build Studio Mode UI
- Collectible system (Cassettes unlock tiles)

## Design Principles

### Audio-Tileset Pattern
One large audio file + metadata = many playable "tiles"
```
level_1_atlas.ogg (5 MB) + level_1_atlas.tres (metadata)
→ 50+ individual samples accessible via offset/length
```

### Level-Bound Assets
Each level/zone has its own MusicAtlas (like TileSets)
- Level 1: Rock theme samples
- Level 2: Electronic theme samples
- Boss levels: Heavy metal samples

### Performance-First
- One file load instead of 100+ individual samples
- RAM-optimized (single buffer)
- Integrated with SCENE_MANAGER's threaded loading

## Integration Points

### SCENE_MANAGER
```gdscript
# Level exports its music atlas
@export var music_atlas: MusicAtlas

# SCENE_MANAGER loads it during threaded scene load
# Music ready when level starts
```

### Savegame System
```gdscript
# Only store:
{
    "current_atlas": "res://path/to/atlas.tres",
    "unlocked_tiles": ["kick_01", "guitar_a"],
    "active_layers": {"drums": "kick_01", "bass": "bass_loop"}
}
```

### Collectibles
```gdscript
# Cassette pickup unlocks new tiles
func _on_cassette_collected(cassette):
    MUSIC_SYSTEM.unlock_tiles(cassette.tile_names)
```

## Usage Example

```gdscript
# Load atlas (done by SCENE_MANAGER)
MUSIC_SYSTEM.load_atlas(level_music_atlas)

# Activate layers during gameplay
MUSIC_SYSTEM.activate_layer("drums", "kick_basic")
MUSIC_SYSTEM.activate_layer("bass", "bass_loop_01")

# Progression
MUSIC_SYSTEM.unlock_tile("guitar_distortion")
MUSIC_SYSTEM.activate_layer("guitar", "guitar_distortion")

# Studio mode
MUSIC_SYSTEM.clear_all_layers()
MUSIC_SYSTEM.activate_layer("drums", player_choice_drums)
MUSIC_SYSTEM.activate_layer("guitar", player_choice_guitar)
```

## Next Steps

When implementing in Venus phase:
1. Create first MusicAtlas resource
2. Integrate music_system.gd as autoload
3. Update SCENE_MANAGER to load atlases
4. Build Studio Mode UI
5. Implement Collectible → Tile unlock flow

## Related Docs

- Architecture: [MUSIC_ATLAS_SYSTEM.md](../../doc/MUSIC_ATLAS_SYSTEM.md)
- Home Studio: [HOME_STUDIO_SYSTEM.md](../../doc/HOME_STUDIO_SYSTEM.md)
- Mercury Roadmap: [MERCURY_PHASE.md](../../doc/MERCURY_PHASE.md)
