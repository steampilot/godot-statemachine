extends RigidBody2D
class_name Ball

## Ball - RigidBody2D mit Attachment-Logik
## Player kann den Ball aufnehmen und tragen
## Ball hat Physik wenn am Boden, ist statisch wenn getragen

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

var attached_player: Player = null
var is_attached: bool = false

func _ready():
    area.body_entered.connect(_on_area_entered)

func _on_area_entered(body: Node3D):
    if body is Player and not is_attached:
        print("⚽ Player touched ball")

## ===== ATTACHMENT INTERFACE =====

func attach_to_player(player: Player):
    # Ball wird an Player angehängt
    if is_attached:
        return

    print("⚽ [Ball] Attaching to player")
    attached_player = player
    is_attached = true

    # Ball wird Kind von AttachmentSlot
    reparent(player.$AttachmentSlot)
    global_position = player.$AttachmentSlot.global_position

    # Ball wird statisch (kein Physics, bis dropped)
    freeze = true
    area.monitoring = false

func drop_at(position: Vector2):
    # Ball fällt auf den Boden
    if not is_attached:
        return

    print("⚽ [Ball] Dropping")
    is_attached = false
    attached_player = null

    # Ball wird wieder Kind der Main-Scene
    var scene_root = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
    reparent(scene_root)
    global_position = position

    # Ball wird wieder dynamisch (Physics aktiv)
    freeze = false
    area.monitoring = true

## Public API

func is_held_by_player() -> bool:
    return is_attached and attached_player != null
