shader_type spatial;
render_mode unshaded;

uniform float current_health : hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec3 bgColor = vec3(0, 0, 0);
	vec3 healthbarColor = mix(vec3(1, 0, 0), vec3(0, 1, 0), current_health);
	float healthbarMask = 0.0;
	
	// linear
	healthbarMask = float(current_health > UV.x);
	
	// cool segmented example
	// float num_segments = 8.0; // Could use int, but no implicit conversion (by design)
	// healthbarMask = float(current_health > floor(UV.x * num_segments) / num_segments);
	
	vec3 outputColor = mix(bgColor, healthbarColor, healthbarMask);
	ALBEDO = outputColor;
}