/*
	Blinn-Phong Specular lighting:
	- Accounts for the shape of the object to convert the circular pattern into a shape
	- Instead of using a reflected vector (R), it uses a half vector. This Half Vector (H) is the average of the Light Vector (L) and the View Vector (V)
		- Calculated using `H = normalize(L + V)`
	- Specular Value is calculated as `dot(H, N)`
	- Because we're using the half vector, we are applying lighting Anisotropically, which is a fancy way of saying one or more axes (XYZ) is streched or squashed.
		- If you're having trouble picturing this, imagine lighting as its own layer like in photo editing.
			Since H is in between orthonormalized vectors you're supposed to use, that lighting layer is tilted.
			When the lighting layer is applied to the overall image, it will come onto the screen a bit skewed.
	
*/
shader_type spatial;

uniform float gloss : hint_range(0.0, 300.0, 0.1) = 1.0; // AKA Specular Exponent
const vec3 red = vec3(1, 0, 0);
const vec3 white = vec3(1, 1, 1);
const vec3 black = vec3(0, 0, 0);

void fragment() {
	ALBEDO = black;
}

void light() {
	vec3 L = LIGHT;
	vec3 N = NORMAL;
	vec3 V = VIEW;
	vec3 H = normalize(L + V);
	vec3 lambert = max(vec3(0, 0, 0), dot(N, L));

	float specular_value = max(0, dot(H, N)) * float(length(lambert) > 0.0);

	// ROUGHNESS CALCULATION
	specular_value = pow(specular_value, gloss);
	vec3 specular_mask = specular_value * vec3(1, 1, 1);
	SPECULAR_LIGHT = specular_mask;
}
