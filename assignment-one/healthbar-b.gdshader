shader_type spatial;
render_mode unshaded;

uniform float current_health : hint_range(0.0, 1.0, 0.01) = 0.5;

// boundaries where the red/green start most-intensely
uniform float health_boundary_low : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float health_boundary_high : hint_range(0.0, 1.0, 0.01) = 0.8;

float inverse_lerp(in float a, in float b, in float value) {
	// Converts a range(a, b) and value to a new normalized t value (between 0 and 1)
	// In other words, wherever value is a, t is 0 and wherever value is b, t is 1
	return (value - a) / (b - a);
}

void fragment() {
	vec3 bgColor = vec3(0, 0, 0);
	float healthbarMask = 0.0;
	
	healthbarMask = float(current_health > UV.x);
	
	// normalize/flatten the health range for the color
	// if low > high, the bar will turn into a buildup bar instead!
	float t_health = inverse_lerp(health_boundary_low, health_boundary_high, current_health);
	t_health = clamp(t_health, 0, 1);
	
	vec3 healthbarColor = mix(vec3(1, 0, 0), vec3(0, 1, 0), t_health);
	
	vec3 outputColor = mix(bgColor, healthbarColor, healthbarMask);
	ALBEDO = outputColor;
}