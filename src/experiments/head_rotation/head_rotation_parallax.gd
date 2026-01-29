extends Sprite2D

# Parallax Occlusion Mapping Test für Head Rotation
# Nutzt Normal Map um Pixel basierend auf Tiefe zu verschieben
# Textures kommen von Child-Nodes statt @export Properties

@export_group("Rotation Settings")
@export var rotation_angle: float = 0.0:
    set(value):
        rotation_angle = clamp(value, -1.0, 1.0)
        _update_shader_params()

@export var auto_rotate: bool = true
@export var rotation_speed: float = 1.0

@export_group("Parallax Settings")
@export var parallax_strength: float = 0.05:
    set(value):
        parallax_strength = value
        _update_shader_params()

@export var parallax_samples: int = 16:
    set(value):
        parallax_samples = clamp(value, 4, 32)
        _update_shader_params()

@export var side_blend_threshold: float = 0.6:
    set(value):
        side_blend_threshold = clamp(value, 0.3, 0.9)
        _update_shader_params()

var shader_material: ShaderMaterial

# Child node references
@onready var front_node: Sprite2D = $FrontNode
@onready var side_left_node: Sprite2D = $SideLeftNode
@onready var side_right_node: Sprite2D = $SideRightNode
@onready var normal_front_node: Sprite2D = $NormalFrontNode
@onready var normal_left_node: Sprite2D = $NormalLeftNode
@onready var normal_right_node: Sprite2D = $NormalRightNode

func _ready() -> void:
    _setup_shader()
    _update_shader_params()

func _setup_shader() -> void:
    var shader: Shader = preload("res://Scenes/head_rotation_blend.gdshader")
    shader_material = ShaderMaterial.new()
    shader_material.shader = shader
    material = shader_material

    # Textures von Child-Nodes laden
    if front_node and front_node.texture:
        texture = front_node.texture
        shader_material.set_shader_parameter("frame_center", front_node.texture)
        print("Loaded front texture: ", front_node.texture.resource_path)
    else:
        push_warning("FrontNode has no texture assigned!")

    if side_left_node and side_left_node.texture:
        shader_material.set_shader_parameter("frame_left", side_left_node.texture)
        print("Loaded left texture: ", side_left_node.texture.resource_path)
    else:
        push_warning("SideLeftNode has no texture assigned!")

    if side_right_node and side_right_node.texture:
        shader_material.set_shader_parameter("frame_right", side_right_node.texture)
        print("Loaded right texture: ", side_right_node.texture.resource_path)
    else:
        push_warning("SideRightNode has no texture assigned!")

    if normal_front_node and normal_front_node.texture:
        shader_material.set_shader_parameter("normal_front", normal_front_node.texture)
        print("Loaded normal map (front): ", normal_front_node.texture.resource_path)
    else:
        push_warning("NormalFrontNode has no texture assigned!")

    if normal_left_node and normal_left_node.texture:
        shader_material.set_shader_parameter("normal_left", normal_left_node.texture)
        print("Loaded normal map (left): ", normal_left_node.texture.resource_path)
    else:
        push_warning("NormalLeftNode has no texture assigned!")

    if normal_right_node and normal_right_node.texture:
        shader_material.set_shader_parameter("normal_right", normal_right_node.texture)
        print("Loaded normal map (right): ", normal_right_node.texture.resource_path)
    else:
        push_warning("NormalRightNode has no texture assigned!")

func _process(delta: float) -> void:
    if not auto_rotate:
        return

    # Smooth sine wave für NEIN-Bewegung
    var time: float = Time.get_ticks_msec() * 0.001 * rotation_speed
    rotation_angle = sin(time)

    _update_shader_params()

func _update_shader_params() -> void:
    if not shader_material:
        return

    shader_material.set_shader_parameter("rotation", rotation_angle)
    shader_material.set_shader_parameter("parallax_strength", parallax_strength)
    shader_material.set_shader_parameter("parallax_samples", parallax_samples)
    shader_material.set_shader_parameter("side_blend_threshold", side_blend_threshold)

func set_head_rotation(angle: float) -> void:
    rotation_angle = clamp(angle, -1.0, 1.0)
    _update_shader_params()

func set_auto_rotate(enabled: bool) -> void:
    auto_rotate = enabled

func set_parallax_strength(strength: float) -> void:
    parallax_strength = strength
    _update_shader_params()
