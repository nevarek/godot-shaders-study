/*
	Specular lighting:
	- Specular means the shiny spot, and it's complicated to calculate when getting into physically-based rendering (PBR). 
	- PBR is the typical standard. Before this standard were Phong and Blinn-Phong, with Blinn-Phong being most believable.
	- I don't recommend PBR if you aren't comfy with calculating arbitrary values in 3D space, the short version is PBR simulates light photons
	- Basic components are the Light vector (L), local normal (N), and the view vector (V). V is from the surface to the camera.
	- Phong perfectly reflects L on the surface, and uses the dot product to calculate how much the camera (`VIEW`) aligns with that reflection.
		- Everything should be clamped becase we don't want negative values
	- Godot precalculates the view vector in the GLSL code and exposes that value as `VIEW` but it's in view space.
		- to calculate it manually, the pseudo code would be vector math: "normalize(camera_world_position - object_world_position);", result is in WORLD SPACE
		- We would then want to bring VIEW **from VIEW SPACE to WORLD SPACE**, so multiply it with `INV_VIEW_MATRIX`
	- Godot offers two channels for lighting output, one is diffuse and one is specular, the two results depend on being used properly!
		- Nerd stuff: quickly glancing at the forward rendering calculation, specular light is divided by the non-zero, positive alpha values found in diffuse light
			- In other words, it's not a commutative relationship, so be careful (or creative!)
	
*/
shader_type spatial;

uniform float gloss : hint_range(0.0, 30.0, 0.1) = 1.0; // AKA Specular Exponent
const vec3 red = vec3(1, 0, 0);
const vec3 white = vec3(1, 1, 1);
const vec3 black = vec3(0, 0, 0);

void fragment() {
	ALBEDO = black; // easier to see
}

void light() {
	// using lambertian lighting
	float diffuse_light_falloff_value = max(0, dot(NORMAL, LIGHT));
	vec3 output = diffuse_light_falloff_value * vec3(1, 1, 1);
	DIFFUSE_LIGHT = output;
	
	// specular light debug: set DIFFUSE_LIGHT to V, then the light is a WORLD SPACE vector pointing toward the camera
	// but, we can write to a particular output called `SPECULAR_LIGHT` that just defines our result
	vec3 V_WORLD = normalize(VIEW * mat3(INV_VIEW_MATRIX)); // VIEW SPACE -> WORLD SPACE
	// DIFFUSE_LIGHT = V_WORLD; // debug, unset the ALBEDO in `fragment()`
	
	// Now we calculate the reflected light vector along the surface normal
	// We don't have to work within world coordinates for this, as long as R is calculated in the same SPACE
	vec3 L = LIGHT; // directional light vector in VIEW SPACE
	vec3 N = NORMAL; // normal in VIEW SPACE
	vec3 V = VIEW; // view in ... VIEW SPACE
	
	vec3 R = normalize(reflect(-L, N));
	// DIFFUSE_LIGHT = R; // debug 
	float lambert = max(0, dot(R, V));
	vec3 specular_mask = lambert * vec3(1, 1, 1);
	// DIFFUSE_LIGHT = specular_mask.xxx; // debug
	SPECULAR_LIGHT = specular_mask; // I'm going to start applying this to the specular pipeline
	
	// ROUGHNESS CALCULATION
	// "specular_output = pow(specular_value, gloss);"
	float specular_value = pow(lambert, gloss);
	specular_mask = specular_value * vec3(1, 1, 1);
	// specular_mask = specular_value * vec3(1, 1, 1) * float(length(lambert)> 0.0); // discussed in next section, it's a cutoff like in the lambertian shader
	SPECULAR_LIGHT = specular_mask;
	
	/* We don't run into Freya's normalization problem, the interpolated normals are auto-normalized in the base shader.
		- I wonder what this means for AO, but AO is a built-in for `fragment()`, for pre-baked AO data as Freya discusses.
			I haven't used this yet, but I'd start there if I wanted to include AO data from sampling the UV.
	*/
}
