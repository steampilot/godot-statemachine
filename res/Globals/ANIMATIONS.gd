extends Node

# Animation name constants for Caprica Player
# Use these constants instead of hardcoded strings for IntelliSense support
# Example: sprite.play(PLAYER.IDLE) instead of sprite.play("idle")
# Note: This is PLAYER-exclusive. Enemies will have their own reduced animation set.

# Movement - Basic
const IDLE = "idle"
const IDLE_FIGHT_STANCE = "idle_fight_stance"
const WALK = "walk"
const WALK_ANGRY = "walk_angry"
const WALK_HURT = "walk_hurt"
const WALK_NORTH = "walk_north"
const WALK_SOUTH = "walk_south"
const RUN = "run"
const RUN_SLIDE = "run_slide"

# Jump & Air Movement
const JUMP_UP = "jump_up"
const JUMP_TOP = "jump_top"
const JUMP_DOWN = "jump_down"
const JUMP_LAND = "jump_land"

# Combat - Kicks
const KICK_HIGH = "kick_high"
const KICK_MID = "kick_mid"
const KICK_LOW = "kick_low"

# Combat - Punches
const PUNCH = "punch"
const PUNCH_UP = "punch_up"

# Special Actions
const DASH = "dash"
const LADDER_GRAB = "ladder_grab"
const GUITAR_STRUM = "guitar_strum"

# Damage & Death
const HURT = "hurt"
const DYING = "dying"

# Animation metadata for advanced usage
const METADATA = {
    IDLE: {"frames": 4, "fps": 4, "loop": true, "source": "breathing-idle"},
    IDLE_FIGHT_STANCE: {"frames": 8, "fps": 8, "loop": true,
    	"source": "fight-stance-idle-8-frames"},
    WALK: {"frames": 6, "fps": 8, "loop": true, "source": "walking-10/east"},
    WALK_ANGRY: {"frames": 8, "fps": 8, "loop": true, "source": "sad-walk/east"},
    WALK_HURT: {"frames": 8, "fps": 5, "loop": true, "source": "sad-walk/south-east"},
    WALK_NORTH: {"frames": 6, "fps": 8, "loop": true, "source": "walk/north"},
    WALK_SOUTH: {"frames": 6, "fps": 5, "loop": true, "source": "walk/south"},
    RUN: {"frames": 8, "fps": 8, "loop": true, "source": "running-8-frames/east"},
    RUN_SLIDE: {"frames": 6, "fps": 5, "loop": false, "source": "running-slide/south-east"},
    JUMP_UP: {"frames": 3, "fps": 8, "loop": false, "source": "jumping-1/east"},
    JUMP_TOP: {"frames": 2, "fps": 2, "loop": false, "source": "jumping-1/east"},
    JUMP_DOWN: {"frames": 2, "fps": 2, "loop": false, "source": "jumping-1/east"},
    JUMP_LAND: {"frames": 3, "fps": 4, "loop": false, "source": "jumping-1/east"},
    KICK_HIGH: {"frames": 7, "fps": 8, "loop": false, "source": "high-kick/east"},
    KICK_MID: {"frames": 6, "fps": 6, "loop": false, "source": "flying-kick/east"},
    KICK_LOW: {"frames": 7, "fps": 8, "loop": false, "source": "leg-sweep/east"},
    PUNCH: {"frames": 6, "fps": 8, "loop": false, "source": "lead-jab/east"},
    PUNCH_UP: {"frames": 7, "fps": 5, "loop": true, "source": "surprise-uppercut/east"},
    DASH: {"frames": 6, "fps": 6, "loop": false, "source": "front-flip/east"},
    LADDER_GRAB: {"frames": 7, "fps": 8, "loop": true, "source": "two-footed-jump/north"},
    GUITAR_STRUM: {"frames": 8, "fps": 8, "loop": false,
    	"source": "pull-heavy-object/south (PowerChord)"},
    HURT: {"frames": 6, "fps": 6, "loop": true, "source": "taking-punch/east"},
    DYING: {"frames": 7, "fps": 8, "loop": false, "source": "falling-back-death/east"}
}

# Helper function to check if animation loops
static func is_looping(animation_name: String) -> bool:
    if METADATA.has(animation_name):
        return METADATA[animation_name]["loop"]
    return false

# Helper function to get animation duration in seconds
static func get_duration(animation_name: String) -> float:
    if METADATA.has(animation_name):
        var meta = METADATA[animation_name]
        return float(meta["frames"]) / float(meta["fps"])
    return 0.0

# Helper function to get frame count
static func get_frame_count(animation_name: String) -> int:
    if METADATA.has(animation_name):
        return METADATA[animation_name]["frames"]
    return 0

# Animation groups for easier management
const MOVEMENT_ANIMATIONS = [WALK, WALK_ANGRY, WALK_HURT, WALK_NORTH, WALK_SOUTH, RUN, RUN_SLIDE]
const IDLE_ANIMATIONS = [IDLE, IDLE_FIGHT_STANCE]
const JUMP_ANIMATIONS = [JUMP_UP, JUMP_TOP, JUMP_DOWN, JUMP_LAND]
const KICK_ANIMATIONS = [KICK_HIGH, KICK_MID, KICK_LOW]
const PUNCH_ANIMATIONS = [PUNCH, PUNCH_UP]
const COMBAT_ANIMATIONS = KICK_ANIMATIONS + PUNCH_ANIMATIONS
const SPECIAL_ANIMATIONS = [DASH, LADDER_GRAB, GUITAR_STRUM]
const DAMAGE_ANIMATIONS = [HURT, DYING]

# Note: Enemies will have their own reduced animation set in a separate global
# Future: ENEMY.IDLE, ENEMY.WALK, ENEMY.ATTACK, etc.
