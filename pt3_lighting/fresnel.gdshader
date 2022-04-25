/*
	Fresnel effect
		- bad for hard edges and non-spherical shapes
		- Calculation is how close the normal is facing our current view vector
			- that's right, a dot product!
			- `1.0 - dot(VIEW, NORMAL)` makes the light mask and you just add it to `DIFFUSE_LIGHT`
*/

shader_type spatial;

uniform float gloss : hint_range(0.0, 1, 0.1) = 1.0; // AKA Specular Exponent
const vec3 white = vec3(1, 1, 1);

void fragment() {
	ALBEDO = white / 4.0; // lazy darkening lol
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

	// animated example
	float fresnel = 1.0 - dot(VIEW, NORMAL);
	float output_fresnel = fresnel * max(0, cos(TIME * 1.0) * 1.5 + 1.5);
	DIFFUSE_LIGHT += output_fresnel * LIGHT_COLOR;
}