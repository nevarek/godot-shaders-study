shader_type canvas_item;

// Configurable in the Inspector as "Shader Param" under the Material
uniform vec4 COLOR_A : hint_color = vec4(.71, .11, .64, 1);
uniform vec4 COLOR_B : hint_color = vec4(.64, .92, 1, 1);

uniform float COLOR_START : hint_range(0, 1) = 0;
uniform float COLOR_END : hint_range(0, 1) = 1;

float inverse_lerp(in float a, in float b, in float value) {
	if (a == b) return 0.0;
	return (value - a) / (b - a);
}

void vertex() {
	//
}

void fragment() {
	float t = inverse_lerp(COLOR_START, COLOR_END, UV.x);
	vec4 outColor = mix(COLOR_A, COLOR_B, UV.x);
	
	// part two: gradient start and end
	// t = fract(t); // repeating pattern
	t = clamp(t, 0, 1); // thank Yuri for not using saturate lmao
	outColor = mix(COLOR_A, COLOR_B, t);
	
	COLOR = outColor;
}