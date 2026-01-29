class_name GhostSprite
extends Sprite2D

# Ghost fade properties
@export var fade_duration: float = 0.4
@export var initial_opacity: float = 0.5

var fade_timer: float = 0.0


func _ready() -> void:
    # Set initial transparency
    modulate.a = initial_opacity
    fade_timer = fade_duration

    # Don't inherit parent's transform scale
    top_level = true

func _process(delta: float) -> void:
    # Fade out over time
    fade_timer -= delta

    if fade_timer <= 0:
        queue_free()
        return

    # Linear fade
    modulate.a = initial_opacity * (fade_timer / fade_duration)
