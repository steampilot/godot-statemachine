extends Sprite2D

# 45-Degree Parallax Rotation System
# Nutzt 1 Base Sprite bei 45° + 1 Normal Map für Full Rotation Range
# Mirror für Front, Displacement für Profile

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

@export var mirror_threshold: float = 0.3:
	set(value):
		mirror_threshold = clamp(value, 0.0, 0.5)
		_update_shader_params()

var shader_material: ShaderMaterial

# Child node references
@onready var texture_45_node: Sprite2D = $Texture45Node
@onready var normal_45_node: Sprite2D = $Normal45Node

func _ready() -> void:
	_setup_shader()
	_update_shader_params()

func _setup_shader() -> void:
	var shader: Shader = preload("res://Scenes/head_rotation_45degree.gdshader")
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material = shader_material
	
	# Load textures from child nodes
	if texture_45_node and texture_45_node.texture:
		texture = texture_45_node.texture
		shader_material.set_shader_parameter("texture_45degree", texture_45_node.texture)
		print("Loaded 45° texture: ", texture_45_node.texture.resource_path)
	else:
		push_warning("Texture45Node has no texture assigned!")
	
	if normal_45_node and normal_45_node.texture:
		shader_material.set_shader_parameter("normal_45degree", normal_45_node.texture)
		print("Loaded 45° normal map: ", normal_45_node.texture.resource_path)
	else:
		push_warning("Normal45Node has no texture assigned!")

func _process(delta: float) -> void:
	if not auto_rotate:
		return
	
	# Smooth sine wave für Kopfdrehung
	var time: float = Time.get_ticks_msec() * 0.001 * rotation_speed
	rotation_angle = sin(time)
	
	_update_shader_params()

func _update_shader_params() -> void:
	if not shader_material:
		return
	
	shader_material.set_shader_parameter("rotation", rotation_angle)
	shader_material.set_shader_parameter("parallax_strength", parallax_strength)
	shader_material.set_shader_parameter("parallax_samples", parallax_samples)
	shader_material.set_shader_parameter("mirror_threshold", mirror_threshold)

# Public API
func set_head_rotation(angle: float) -> void:
	rotation_angle = clamp(angle, -1.0, 1.0)
	_update_shader_params()

func set_auto_rotate(enabled: bool) -> void:
	auto_rotate = enabled

func set_parallax_strength(strength: float) -> void:
	parallax_strength = strength
	_update_shader_params()
