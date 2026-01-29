extends Node
class_name PortalClipping

## Portal-Clipping-System für visuelle Kontinuität
## Managed das Rendering von Player/Puppet beim Crossing

## Clipping-Material für Shader-basiertes Clipping
var _clip_shader_material: ShaderMaterial

## Ist Clipping aktiv?
var _clipping_active: bool = false

## Portal-Zentrum für Clipping-Berechnung
var _clip_portal_position: Vector2

## Clipping-Richtung: "LEFT" oder "RIGHT"
var _clip_direction: String

## Spiel-Node mit Sprite2D
var _parent: Node2D


func _ready() -> void:
    _parent = get_parent()


## Aktiviere Portal-Clipping auf einem Node
func enable_clipping(portal_pos: Vector2, direction: String) -> void:
    _clipping_active = true
    _clip_portal_position = portal_pos
    _clip_direction = direction

    _setup_clipping_shader()


## Deaktiviere Portal-Clipping
func disable_clipping() -> void:
    _clipping_active = false

    if _parent and _parent.has_node("Sprite2D"):
        var sprite = _parent.get_node("Sprite2D")
        sprite.self_modulate = Color.WHITE


## Setup Shader für smoothes Clipping
func _setup_clipping_shader() -> void:
    if not _parent or not _parent.has_node("Sprite2D"):
        return

    var sprite = _parent.get_node("Sprite2D")

    # Erstelle Shader-Material wenn nicht vorhanden
    if not _clip_shader_material:
        _clip_shader_material = ShaderMaterial.new()
        _clip_shader_material.shader = _create_portal_clip_shader()

    sprite.material = _clip_shader_material

    # Update Shader-Parameter
    _update_shader_parameters()


## Erstelle Portal-Clipping-Shader
func _create_portal_clip_shader() -> Shader:
    var shader_code = """
shader_type canvas_item;

uniform vec2 portal_position = vec2(0.0);
uniform float clip_distance = 50.0;
uniform int clip_direction = 0;  // 0 = RIGHT, 1 = LEFT

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    // Berechne Distanz zur Portal-Position
    float distance_to_portal = abs(WORLD_VERTEX.x - portal_position.x);

    // Berechne Alpha basierend auf Distanz
    float fade_factor = smoothstep(0.0, clip_distance, distance_to_portal);

    // Je nach Richtung: Fade-Out auf unterschiedlichen Seiten
    if (clip_direction == 0) {
        // RIGHT: Fade aus wenn rechts vom Portal
        if (WORLD_VERTEX.x > portal_position.x) {
            original_color.a *= (1.0 - fade_factor);
        }
    } else {
        // LEFT: Fade aus wenn links vom Portal
        if (WORLD_VERTEX.x < portal_position.x) {
            original_color.a *= (1.0 - fade_factor);
        }
    }

    COLOR = original_color;
}
"""
    var shader = Shader.new()
    shader.code = shader_code
    return shader


## Update Shader-Parameter für aktuelle Position
func _update_shader_parameters() -> void:
    if not _clip_shader_material:
        return

    # Konvertiere World-Position zu Shader-Koordinaten
    var portal_pos = _clip_portal_position
    _clip_shader_material.set_shader_parameter("portal_position", portal_pos)

    # Clipping-Distanz (wie schnell der Fade-Out ist)
    _clip_shader_material.set_shader_parameter("clip_distance", 50.0)

    # Clipping-Richtung
    var direction_int = 0 if _clip_direction == "RIGHT" else 1
    _clip_shader_material.set_shader_parameter("clip_direction", direction_int)


## Alternative: CPU-basiertes Clipping ohne Shader
func _apply_cpu_clipping() -> void:
    if not _parent or not _parent.has_node("Sprite2D"):
        return

    var sprite = _parent.get_node("Sprite2D")
    var player_center = _parent.global_position.x
    var clip_center = _clip_portal_position.x

    # Einfache Fade-Out basierend auf Position
    if _clip_direction == "RIGHT":
        # Fade aus wenn Player rechts vom Portal
        if player_center > clip_center:
            var distance = player_center - clip_center
            var alpha = max(0.3, 1.0 - (distance / 50.0))
            sprite.self_modulate.a = alpha
        else:
            sprite.self_modulate.a = 1.0
    elif _clip_direction == "LEFT":
        # Fade aus wenn Player links vom Portal
        if player_center < clip_center:
            var distance = clip_center - player_center
            var alpha = max(0.3, 1.0 - (distance / 50.0))
            sprite.self_modulate.a = alpha
        else:
            sprite.self_modulate.a = 1.0
