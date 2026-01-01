shader_type canvas_item;

// Parallax Occlusion Mapping für 2D Head Rotation
// Nutzt Normal Map um Pixel basierend auf 3D Shape zu verschieben

uniform sampler2D frame_center : filter_nearest, repeat_disable;
uniform sampler2D frame_left : filter_nearest, repeat_disable;
uniform sampler2D frame_right : filter_nearest, repeat_disable;

// Normal Maps: RGB = XYZ Normale vom 3D Shape (je View)
uniform sampler2D normal_front : filter_nearest, repeat_disable;
uniform sampler2D normal_left : filter_nearest, repeat_disable;
uniform sampler2D normal_right : filter_nearest, repeat_disable;

// Rotation: -1.0 = links, 0.0 = center, 1.0 = rechts
uniform float rotation : hint_range(-1.0, 1.0) = 0.0;

// Stärke des Parallax-Effekts (wie stark Pixel verschoben werden)
uniform float parallax_strength : hint_range(0.0, 0.2) = 0.05;

// Anzahl der Depth-Samples für bessere Qualität
uniform int parallax_samples : hint_range(4, 32) = 16;

// Blending-Schwelle: Ab welchem Winkel zu Side-View wechseln
uniform float side_blend_threshold : hint_range(0.3, 0.9) = 0.7;

void fragment() {
	// Wähle korrekte Normal Map basierend auf Rotation
	sampler2D active_normal;
	if (abs(rotation) < 0.3) {
		active_normal = normal_front;
	} else if (rotation < 0.0) {
		active_normal = normal_left;
	} else {
		active_normal = normal_right;
	}
	
	// Lese Normal Map (RGB = XYZ, konvertiert von [0,1] zu [-1,1])
	vec3 normal = texture(active_normal, UV).rgb * 2.0 - 1.0;
	
	// Nutze Z-Komponente (Blau) als Depth/Height
	// Z zeigt aus dem Bild raus: höhere Werte = näher zur Kamera
	float height = normal.z;
	
	// View Direction basierend auf Rotation
	// Bei Rotation nach links: View kommt von rechts
	vec3 view_dir = normalize(vec3(-rotation, 0.0, 1.0));
	
	// Parallax Displacement basierend auf Normal Map
	// X-Normale (Rot) bestimmt horizontale Verschiebung
	vec2 parallax_offset = vec2(0.0);
	
	// Iteratives Ray-Marching durch Height Field
	float layer_depth = 1.0 / float(parallax_samples);
	float current_layer_depth = 0.0;
	vec2 delta_uv = view_dir.xy * parallax_strength / float(parallax_samples);
	vec2 current_uv = UV;
	float current_height = height;
	
	// Ray-marching: Finde Intersection mit Height Field
	for (int i = 0; i < parallax_samples; i++) {
		if (current_layer_depth >= current_height) {
			break;
		}
		
		current_uv -= delta_uv;
		vec3 current_normal = texture(active_normal, current_uv).rgb * 2.0 - 1.0;
		current_height = current_normal.z;
		current_layer_depth += layer_depth;
	}
	
	// Parallax Occlusion: Interpolation zwischen letzten 2 Samples
	vec2 prev_uv = current_uv + delta_uv;
	float next_height = current_height;
	float prev_height = texture(active_normal, prev_uv).rgb.b * 2.0 - 1.0;
	
	float after_depth = next_height - current_layer_depth;
	float before_depth = prev_height - (current_layer_depth - layer_depth);
	float weight = after_depth / (after_depth - before_depth);
	
	vec2 final_uv = mix(current_uv, prev_uv, weight);
	
	// Clamp UV to valid range
	if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
		discard;
	}
	
	// Sample Color mit verschobenem UV
	vec4 color_center = texture(frame_center, final_uv);
	
	// Optional: Blende mit Side-Views bei extremen Winkeln
	vec4 final_color = color_center;
	float abs_rotation = abs(rotation);
	
	if (abs_rotation > side_blend_threshold) {
		float blend_factor = (abs_rotation - side_blend_threshold) / (1.0 - side_blend_threshold);
		blend_factor = smoothstep(0.0, 1.0, blend_factor);
		
		if (rotation < 0.0) {
			// Blend mit Links
			vec4 color_left = texture(frame_left, UV);
			final_color = mix(color_center, color_left, blend_factor);
		} else {
			// Blend mit Rechts
			vec4 color_right = texture(frame_right, UV);
			final_color = mix(color_center, color_right, blend_factor);
		}
	}
	
	COLOR = final_color;
}
