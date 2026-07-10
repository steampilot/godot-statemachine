class_name PlayerZelda
extends CharacterBody2D

## Simple Zelda-style top-down player movement
## Used for Zelda transition system testing

# signal entered_door(door: ZeldaDoor)

const SPEED: float = 100.0

@export var input_enabled: bool = true
var move_dir: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
# @onready var animation_player: AnimationPlayer = $AnimationPlayer # TODO: Add when animations
# ready


func _physics_process(_delta: float) -> void:
    if not input_enabled:
        return

    move_dir = Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    )
    orient(move_dir)

    # TODO: Uncomment when animations exist
    # if move_dir != Vector2.ZERO:
    #     animation_player.play("walk")
    # else:
    #     animation_player.play("idle")

    if move_dir != Vector2.ZERO:
        var diagonal_dampening: float = 1.0
        if velocity.x != 0 and velocity.y != 0:
            diagonal_dampening = 0.7
        velocity.x = move_dir.x * SPEED * diagonal_dampening
        velocity.y = move_dir.y * SPEED * diagonal_dampening
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.y = move_toward(velocity.y, 0, SPEED)

    move_and_slide()

func orient(dir: Vector2) -> void:
    if dir.x:
        sprite.flip_h = dir.x < 0

func disable() -> void:
    input_enabled = false
    # animation_player.play("idle")  # TODO: Uncomment when animations exist
    velocity = Vector2.ZERO

func enable() -> void:
    input_enabled = true
    visible = true
