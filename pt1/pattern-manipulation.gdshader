shader_type canvas_item;

float inverse_lerp(in float a, in float b, in float value) {
	if (a == b) return 0.0;
	return (value - a) / (b - a);
}

void vertex() {
	//
}

void fragment() {
	int numRepeats = 1;
	// using TAU to oscillate from 0 to 1
	/*
	// float t = cos(UV.x * TAU * 2.0) * 0.5 + 0.5; // basic implementation
	numRepeats = 2;
	vec2 t = cos(UV.xy * TAU * float(numRepeats)) * 0.5 + 0.5;
	COLOR = vec4(t, 1, 1); // trans thriving :O
	*/


	// Important note: we negate UV.y here to reflect what is shown in the video lecture
	//   because we are using a right-handed coordinate system and Unity is left-handed.
	//   In other words, our Y-axis is the opposite direction.
	numRepeats = 5;
	// float xOffset = -UV.y;
	float xOffset = sin(-UV.y * TAU * 8.0) * 0.01;
	float t = cos((UV.x + xOffset + TIME * 0.1) * TAU * float(numRepeats)) * 0.5 + 0.5;
	COLOR = vec4(t, t, t, 1);
	
	
}