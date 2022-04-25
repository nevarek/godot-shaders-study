/*
	Lambertian lighting:
	Used for diffuse lighting, implements lighting where the negative values of L are set to zero:
		`max(0, N.dot(L))`
	- We output the result to `DIFFUSE_LIGHT` vec3 (alpha output is the usual ALPHA float).
	- `DIFFUSE_LIGHT`, `SPECULAR_LIGHT`, and `ALPHA` are the only things you can modify in `light()`.
	- `light()` is a fragment shader calculated after `fragment()`
		- modifying ALPHA will dump the material to the transparency pipeline
	- Light vector is `LIGHT`, but is in VIEW SPACE.
	- NORMAL contains the normal vector in VIEW SPACE.
	- PAY VERY CLOSE ATTENTION TO WHAT VECTOR IS IN WHAT SPACE. MAKE SURE YOUR CALCUATIONS ARE IN THE SAME SPACE OR WEIRD STUFF HAPPENS.
		- I take my intimate knowledge for granted, but if you forget which matrix does what, refer to the documentation:
			https://docs.godotengine.org/en/latest/tutorials/shaders/shader_reference/spatial_shader.html#light-built-ins
	- Fiddling with `DIFFUSE_LIGHT = LIGHT` is hand-dependent, and godot is right-handed with Y up. 
		Unity is left-handed with Y-up. This means the X axis will be inverted, hence the behavior
		in the first testing phase in the video.
		See Freya's photo: https://twitter.com/FreyaHolmer/status/1325556229410861056/photo/1
		
	- LIGHT_COLOR is an input constant describing this fragment's current output of light color with its intensity.
*/
shader_type spatial;

const vec3 red = vec3(1, 0, 0);
const vec3 green = vec3(0, 1, 0);
const vec3 blue = vec3(0, 0, 1);
const vec3 white = vec3(1, 1, 1);


void fragment() {
	ALBEDO = red + blue + green; // think of this like setting the "bits" of ALBEDO
}


void light() {
	// To debug the light vector like in the video, transform it to WORLD SPACE we use the `INV_VIEW_MATRIX`,
	// 		similar to the global vs local normals example in part 1.
	vec3 L_WORLD = LIGHT * mat3(INV_VIEW_MATRIX);
	// DIFFUSE_LIGHT = L_WORLD; // debug
	
	// using lambertian lighting
	// we don't need the view matrix transformation here, both are in VIEW SPACE
	float lambert = max(0, dot(NORMAL, LIGHT));
	
	// It's better to think of lighting as a mask (see the healthbar section for other masks)
	// 		- It doesn't really hold color values, just the intensity at which diffuse light should emit on each channel of RGB.
	vec3 diffuse_light_mask = lambert * vec3(1, 1, 1);

	
	// Colors, and ALBEDO in lighting:
	/* 
	 	- To set the light color, modify the DirectionalLight3D and use LIGHT_COLOR in calculations.
		- Now that we're working with diffuse light, ALBEDO becomes important to understand.
	 	- ALBEDO is not a material's color, though it can behave that way. It's a measure of how much diffuse light gets reflected, and has RGB channels.
	 		- ALBEDO determines which channels should get seen in the diffuse light, and at what intensity.
			- The diffuse light mask we use emits light on all three channels.
	 	- If our diffuse light only emits on the red channel, and the ALBEDO for that channel is zero, there is no diffuse light.
	 		- You can test this by modifying the ALBEDO in the `fragment()` function, by removing the red channel, and only emitting red diffuse light:
				- `ALBEDO = blue + green` in the fragment function, removing the red channel
				- `DIFFUSE_LIGHT = diffuse_light_mask * red` below, emitting the mask only on red
				- Result will be a very dark cyan object
		- Both ALBEDO and DIFFUSE_LIGHT can push results beyond the range of -1 to 1.
	*/
	
	// ALBEDO and ATTENUATION do nothing for this next part, but matters a lot when you have multiple lights and/or non-directional lights
	// 	- To make lights additive, use `+=` (additive) instead of `=` (replacement)
	DIFFUSE_LIGHT = diffuse_light_mask * ALBEDO * ATTENUATION;
}
