shader_type spatial;

varying vec3 normal;

void vertex() {
	// calculation can be done per vertex to optimize it (not necessary here, but important to note)
	mat3 worldBasis = MODEL_NORMAL_MATRIX;
	normal = worldBasis * NORMAL;
}

void fragment() {
	// ALBEDO = NORMAL; // local space
	ALBEDO = normal; // world space
}