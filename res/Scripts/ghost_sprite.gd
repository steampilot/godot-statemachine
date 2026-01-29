class_name GhostSprite
extends Sprite2D

# Ghost fade properties
@export var fade_duration: float = 0.4
@export var initial_opacity: float = 0.5

# LSL State Machine Pattern
enum InternalState {DEFAULT, FADING}
var internal_state: InternalState = InternalState.DEFAULT

var timer_fade: float = 0.0


func _ready() -> void:
    state_entry_default()

# State: DEFAULT
func state_entry_default() -> void:
    # Set initial transparency
    modulate.a = initial_opacity
    timer_fade = fade_duration

    # Don't inherit parent's transform scale
    top_level = true

    # Transition to FADING state
    internal_state = InternalState.FADING
    state_entry_fading()

# State: FADING
func state_entry_fading() -> void:
    # Fading state is active - timer runs in _process
    pass

func _process(delta: float) -> void:
    if internal_state == InternalState.FADING:
        process_fading_state(delta)

func process_fading_state(delta: float) -> void:
    # Update fade timer
    timer_fade -= delta

    # Timer listener: Fade completed
    if timer_fade <= 0:
        timer_listener_fade_complete()
        return

    # Linear fade
    modulate.a = initial_opacity * (timer_fade / fade_duration)

# Timer Listener: Fade Complete
func timer_listener_fade_complete() -> void:
    queue_free()
