shader_type spatial;

void fragment() {
	int numRepeats = 5;
	float xOffset = sin(-UV.y * TAU * 8.0) * 0.01;
	float t = cos((UV.x + xOffset + TIME * 0.1) * TAU * float(numRepeats)) * 0.5 + 0.5;
	ALBEDO = vec3(t, t, t);
}