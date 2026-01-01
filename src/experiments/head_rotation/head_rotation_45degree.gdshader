shader_type canvas_item;

// 45-Degree Parallax Rotation System
// Base Image: Character at 45° angle to camera (3/4 view)
// Rotation: Displacement + Mirror für Full Range

// Base Texture: 45° 3/4 view (enthält beide Augen, Profil-Info)
uniform sampler2D texture_45degree : filter_nearest, repeat_disable;

// Normal Map: RGB = XYZ vom 3D Shape (bei 45° gerendert)
uniform sampler2D normal_45degree : filter_nearest, repeat_disable;

// Rotation: -1.0 = Profile links, 0.0 = Front (mirror), 1.0 = Profile rechts
uniform float rotation : hint_range(-1.0, 1.0) = 0.0;

// Stärke des Parallax-Effekts
uniform float parallax_strength : hint_range(0.0, 0.2) = 0.05;

// Ray-marching Qualität
uniform int parallax_samples : hint_range(4, 32) = 16;

// Mirror Threshold: Ab welchem Winkel wird gespiegelt?
uniform float mirror_threshold : hint_range(0.0, 0.5) = 0.3;

void fragment() {
	vec2 uv = UV;
	
	// Bestimme ob Mirror aktiv ist (für Front-View)
	bool use_mirror = abs(rotation) < mirror_threshold;
	
	// Bei Mirror: Horizontal flip
	if (use_mirror && rotation < 0.0) {
		uv.x = 1.0 - uv.x;
	}
	
	// Lese Normal Map
	vec3 normal = texture(normal_45degree, uv).rgb * 2.0 - 1.0;
	float height = normal.z;
	
	// View Direction basierend auf Rotation
	// Normalisiert: -1.0 (links) → 0.0 (mitte) → 1.0 (rechts)
	float normalized_rotation = rotation;
	if (use_mirror) {
		normalized_rotation = 0.0;
	}
	
	vec3 view_dir = normalize(vec3(-normalized_rotation, 0.0, 1.0));
	
	// Parallax Occlusion Mapping: Ray-marching
	float layer_depth = 1.0 / float(parallax_samples);
	float current_layer_depth = 0.0;
	vec2 delta_uv = view_dir.xy * parallax_strength / float(parallax_samples);
	vec2 current_uv = uv;
	float current_height = height;
	
	// Ray-marching durch Height Field
	for (int i = 0; i < parallax_samples; i++) {
		if (current_layer_depth >= current_height) {
			break;
		}
		
		current_uv -= delta_uv;
		vec3 current_normal = texture(normal_45degree, current_uv).rgb * 2.0 - 1.0;
		current_height = current_normal.z;
		current_layer_depth += layer_depth;
	}
	
	// Parallax Occlusion: Interpolation für Smoothness
	vec2 prev_uv = current_uv + delta_uv;
	float next_height = current_height;
	float prev_height = texture(normal_45degree, prev_uv).rgb.b * 2.0 - 1.0;
	
	float after_depth = next_height - current_layer_depth;
	float before_depth = prev_height - (current_layer_depth - layer_depth);
	float weight = after_depth / (after_depth - before_depth);
	
	vec2 final_uv = mix(current_uv, prev_uv, weight);
	
	// Clamp UV to valid range
	if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
		discard;
	}
	
	// Sample finale Color mit Displacement
	vec4 color = texture(texture_45degree, final_uv);
	
	// Optional: Fade out bei extremen Winkeln (Occlusion)
	float edge_fade = 1.0;
	if (abs(rotation) > 0.7) {
		edge_fade = 1.0 - smoothstep(0.7, 1.0, abs(rotation));
		color.a *= edge_fade;
	}
	
	COLOR = color;
}
