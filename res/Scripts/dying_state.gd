class_name DyingState
extends State

# References to nodes in TSCN
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $Control/ColorRect


func enter() -> void:
    super.enter()
    print("Entered Dying State - Game Over!")

    # Stop all velocity
    parent.velocity = Vector2.ZERO

    # Disable collisions (ignored by enemies)
    parent.set_collision_layer_value(1, false) # Layer 1 = "World"
    parent.set_collision_mask_value(1, false) # Layer 1 = "World"

    # Reset color rect
    if color_rect:
        color_rect.modulate.a = 0.0
        color_rect.visible = true

    # Wait for sprite dying animation to finish, then start death sequence
    if parent.sprite and not parent.sprite.animation_finished.is_connected(
        _on_sprite_animation_finished):
        parent.sprite.animation_finished.connect(
            _on_sprite_animation_finished)

func exit() -> void:
    # Disconnect signal
    if parent.sprite and parent.sprite.animation_finished.is_connected(
        _on_sprite_animation_finished):
        parent.sprite.animation_finished.disconnect(
            _on_sprite_animation_finished)

    # Stop animation player
    if animation_player:
        animation_player.stop()

    # Hide color rect
    if color_rect:
        color_rect.visible = false
        color_rect.modulate.a = 0.0

    # Re-enable collisions
    parent.set_collision_layer_value(1, true) # Layer 1 = "World"
    parent.set_collision_mask_value(1, true) # Layer 1 = "World"

    # Reset player opacity
    parent.sprite.modulate.a = 1.0

func process_input(_event: InputEvent) -> State:
    # No input during death sequence
    return null

func process_physics(_delta: float) -> State:
    # No movement during death
    parent.velocity = Vector2.ZERO

    # No gravity
    gravity_multiplier = 0.0

    return null


func _on_sprite_animation_finished() -> void:
    # Only trigger for dying animation
    if parent.sprite and parent.sprite.animation == animation_name:
        print("Dying animation completed, starting death sequence")
        # Start the AnimationPlayer death sequence
        if animation_player and animation_player.has_animation("death_sequence"):
            animation_player.play("death_sequence")


func reset_level() -> void:
    print("Resetting level...")

    # Hide and reset color rect BEFORE scene reload
    if color_rect:
        color_rect.visible = false
        color_rect.modulate.a = 0.0
        print("Red overlay hidden")

    # Reset player health
    parent.health = parent.max_health

    # Reset player position (TODO: to checkpoint or level start)
    parent.position = Vector2.ZERO

    # Reload current scene
    get_tree().reload_current_scene()
