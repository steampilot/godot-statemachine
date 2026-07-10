extends Node3D

class_name SpriteRenderer3D

## Tool for rendering 3D models to 2D sprites with normal maps
## Usage:
## 1. Load FBX model as child
## 2. Configure export settings
## 3. Call render_sprite() or render_animation_sequence()

@export_group("Model Setup")
@export var model: Node3D
@export var camera_distance: float = 3.0
@export var camera_angle_vertical: float = 45.0 # Degrees from horizontal
@export var camera_angle_horizontal: float = 45.0 # Degrees rotation around Y-axis

@export_group("Output Settings")
@export var output_path: String = "res://SCRATCH/sprite_renders/"
@export var sprite_size: Vector2i = Vector2i(256, 256)
@export var render_albedo: bool = true
@export var render_normals: bool = true
@export var background_transparent: bool = true

@export_group("Animation")
@export var animation_player: AnimationPlayer
@export var animation_name: String = "idle"
@export var frame_count: int = 8
@export var fps: float = 12.0

@export_group("Paperdoll Parts")
@export var render_parts_separately: bool = false
@export var part_names: Array[String] = ["body", "head", "legs", "arms"]

var viewport_color: SubViewport
var viewport_normal: SubViewport
var camera_color: Camera3D
var camera_normal: Camera3D
var directional_light: DirectionalLight3D

func _ready() -> void:
    if Engine.is_editor_hint():
        setup_viewports()

func setup_viewports() -> void:
    # Create color viewport
    viewport_color = SubViewport.new()
    viewport_color.size = sprite_size
    viewport_color.transparent_bg = background_transparent
    viewport_color.render_target_update_mode = SubViewport.UPDATE_DISABLED
    add_child(viewport_color)

    # Create normal viewport
    viewport_normal = SubViewport.new()
    viewport_normal.size = sprite_size
    viewport_normal.transparent_bg = background_transparent
    viewport_normal.render_target_update_mode = SubViewport.UPDATE_DISABLED
    add_child(viewport_normal)

    # Setup cameras (orthogonal projection for pixel-perfect sprites)
    setup_camera(viewport_color, true)
    setup_camera(viewport_normal, false)

    # Clone model into both viewports
    if model:
        clone_model_to_viewport(viewport_color)
        clone_model_to_viewport(viewport_normal)

func setup_camera(viewport: SubViewport, is_color_pass: bool) -> void:
    var camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 2.0 # Orthographic size

    # Calculate 45-degree isometric position
    var angle_v_rad = deg_to_rad(camera_angle_vertical)
    var angle_h_rad = deg_to_rad(camera_angle_horizontal)

    camera.position = Vector3(
        cos(angle_h_rad) * camera_distance * cos(angle_v_rad),
        sin(angle_v_rad) * camera_distance,
        sin(angle_h_rad) * camera_distance * cos(angle_v_rad)
    )
    camera.look_at(Vector3.ZERO, Vector3.UP)

    viewport.add_child(camera)

    if is_color_pass:
        camera_color = camera
        # Add lighting for color pass
        var light = DirectionalLight3D.new()
        light.light_energy = 1.0
        light.rotation = camera.rotation
        viewport.add_child(light)
    else:
        camera_normal = camera

func clone_model_to_viewport(viewport: SubViewport) -> void:
    if not model:
        return

    var model_clone = model.duplicate()
    viewport.add_child(model_clone)

    # For normal pass, apply normal visualization shader
    if viewport == viewport_normal:
        apply_normal_shader(model_clone)

func apply_normal_shader(node: Node) -> void:
    # Apply shader that outputs world-space normals as RGB
    var normal_shader = preload("res://Scripts/normal_output.gdshader")

    if node is MeshInstance3D:
        var material = ShaderMaterial.new()
        material.shader = normal_shader
        node.material_override = material

    # Recursively apply to children
    for child in node.get_children():
        apply_normal_shader(child)

@export_tool_button("Render Current Frame")
func render_sprite() -> void:
    if not model:
        push_error("No model assigned!")
        return

    if not viewport_color or not viewport_normal:
        setup_viewports()

    # Ensure output directory exists
    DirAccess.make_dir_recursive_absolute(output_path)

    # Render color pass
    if render_albedo:
        viewport_color.render_target_update_mode = SubViewport.UPDATE_ONCE
        await RenderingServer.frame_post_draw
        var img_color = viewport_color.get_texture().get_image()
        var filename_color = output_path + "sprite_color.png"
        img_color.save_png(filename_color)
        print("Saved: ", filename_color)

    # Render normal pass
    if render_normals:
        viewport_normal.render_target_update_mode = SubViewport.UPDATE_ONCE
        await RenderingServer.frame_post_draw
        var img_normal = viewport_normal.get_texture().get_image()
        var filename_normal = output_path + "sprite_normal.png"
        img_normal.save_png(filename_normal)
        print("Saved: ", filename_normal)

@export_tool_button("Render Animation Sequence")
func render_animation_sequence() -> void:
    if not animation_player:
        push_error("No AnimationPlayer assigned!")
        return

    if not animation_player.has_animation(animation_name):
        push_error("Animation not found: ", animation_name)
        return

    var animation = animation_player.get_animation(animation_name)
    var duration = animation.length
    var time_step = 1.0 / fps

    for frame in range(frame_count):
        var time = (frame / float(frame_count)) * duration
        animation_player.seek(time, true)

        # Wait for pose update
        await get_tree().process_frame

        # Render both passes
        if render_albedo:
            viewport_color.render_target_update_mode = SubViewport.UPDATE_ONCE
            await RenderingServer.frame_post_draw
            var img = viewport_color.get_texture().get_image()
            var filename = "%s%s_color_%03d.png" % [output_path, animation_name, frame]
            img.save_png(filename)
            print("Saved: ", filename)

        if render_normals:
            viewport_normal.render_target_update_mode = SubViewport.UPDATE_ONCE
            await RenderingServer.frame_post_draw
            var img = viewport_normal.get_texture().get_image()
            var filename = "%s%s_normal_%03d.png" % [output_path, animation_name, frame]
            img.save_png(filename)
            print("Saved: ", filename)

@export_tool_button("Render All Animations")
func render_all_animations() -> void:
    if not animation_player:
        push_error("No AnimationPlayer assigned!")
        return

    var animations = animation_player.get_animation_list()
    for anim in animations:
        animation_name = anim
        await render_animation_sequence()
        print("Completed animation: ", anim)
