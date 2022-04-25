/*
	- Remapping `gloss`, it's now a range from 0 to 1
	- Getting some color
*/
shader_type spatial;

uniform float gloss : hint_range(0.0, 1, 0.1) = 1.0; // AKA Specular Exponent
const vec3 red = vec3(1, 0, 0);
const vec3 white = vec3(1, 1, 1);
const vec3 black = vec3(0, 0, 0);

void fragment() {
	ALBEDO = white;
}

void light() {
	vec3 L = LIGHT;
	vec3 N = NORMAL;
	vec3 V = VIEW;
	vec3 H = normalize(L + V);
	vec3 lambert = max(vec3(0, 0, 0), dot(N, L));

	float specular_value = max(0, dot(H, N)) * float(length(lambert) > 0.0);

	// ROUGHNESS CALCULATION: LINEARLIZED!
	float specular_exponent = exp2(gloss * 6.0) + 2.0; // best to move this value into script instead and pass it in
	specular_value = pow(specular_value, specular_exponent);
	vec3 specular_mask = specular_value * vec3(1, 1, 1);
	
	// adding in color to our masks
	vec3 spec_light = LIGHT_COLOR * specular_mask;
	SPECULAR_LIGHT = spec_light;
	DIFFUSE_LIGHT = lambert * LIGHT_COLOR;
}
