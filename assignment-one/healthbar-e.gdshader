/*
	When defining flashing animations, general steps are:
	1. Determine curve for flashing behavior. Ease In/Out? Sine wave?
	2. Calculate a curve, amplitude, frequency, etc. based on the time.
	3. Find out if extreme values in your calculation are OK, if not, adjust them.
*/
shader_type spatial;
render_mode unshaded;

uniform float current_health : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec4 background_color : hint_color = vec4(0, 0, 0, 1);
uniform sampler2D healthbar_texture : hint_black_albedo, repeat_disable, filter_linear;

// boundaries where the red/green start most-intensely
uniform float health_boundary_low : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float health_boundary_high : hint_range(0.0, 1.0, 0.01) = 0.8;

void fragment() {
	vec3 bgColor = background_color.xyz;
	float healthbarMask = 0.0;
	
	healthbarMask = float(current_health > UV.x);
		
	// read from texture
	vec2 sample_coords = vec2(current_health, UV.y);
	vec4 sample = texture(healthbar_texture, sample_coords);
	vec3 outputColor = sample.xyz * healthbarMask;
	
	if (current_health < health_boundary_low) {
		// modify outputColor by our flashing behavior
		float frequency = 4.0;
		float amplitude = 0.4;
		float flash = cos(TIME * frequency) * amplitude + 1.0;
		outputColor *= flash;
	}
	
	ALBEDO = outputColor;
}