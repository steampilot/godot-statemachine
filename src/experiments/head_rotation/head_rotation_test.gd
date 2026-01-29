extends Sprite2D

# Frame-Switching System für subtile Kopfdrehung
# Links ( *. *) → Mitte ( *.* ) → Rechts (*.  *)

@export_group("Head Rotation Frames")
@export var frame_left: Texture2D
@export var frame_center_left: Texture2D
@export var frame_center: Texture2D
@export var frame_center_right: Texture2D
@export var frame_right: Texture2D

@export_group("Animation Settings")
@export var rotation_speed: float = 1.5
@export var auto_animate: bool = true
@export var manual_rotation: float = 0.5:
    set(value):
        manual_rotation = clamp(value, 0.0, 1.0)
        _update_frame()

var frames: Array[Texture2D] = []
var current_rotation: float = 0.5

func _ready() -> void:
    _setup_frames()
    _update_frame()

func _setup_frames() -> void:
    frames.clear()
    if frame_left:
        frames.append(frame_left)
    if frame_center_left:
        frames.append(frame_center_left)
    if frame_center:
        frames.append(frame_center)
    if frame_center_right:
        frames.append(frame_center_right)
    if frame_right:
        frames.append(frame_right)

    if frames.is_empty():
        push_warning("HeadRotationTest: No frames assigned!")

func _process(delta: float) -> void:
    if not auto_animate:
        return

    # "NEIN"-Bewegung: Smooth sine wave
    var time: float = Time.get_ticks_msec() * 0.001 * rotation_speed
    current_rotation = (sin(time) + 1.0) * 0.5

    _update_frame()

func _update_frame() -> void:
    if frames.is_empty():
        return

    var rotation_value: float = current_rotation if auto_animate else manual_rotation

    # Frame Index berechnen (0.0 → 0, 0.5 → 2, 1.0 → 4)
    var frame_index: int = int(rotation_value * (frames.size() - 1))
    frame_index = clamp(frame_index, 0, frames.size() - 1)

    texture = frames[frame_index]

# Public API für externe Steuerung
func set_head_rotation(rotation_value: float) -> void:
    current_rotation = clamp(rotation_value, 0.0, 1.0)
    _update_frame()
