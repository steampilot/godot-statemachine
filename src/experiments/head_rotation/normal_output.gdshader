shader_type spatial;
render_mode unshaded, cull_disabled;

void fragment() {
	// Output world-space normals as RGB color
	// Transform from [-1, 1] to [0, 1] range
	vec3 world_normal = normalize(NORMAL);
	ALBEDO = world_normal * 0.5 + 0.5;
	
	// Full opacity where model exists
	ALPHA = 1.0;
}

void vertex() {
	// Pass through vertex shader
}
