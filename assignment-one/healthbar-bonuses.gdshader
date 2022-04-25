/*
	1. Create a uniform coordinate system for the streched capsule shape. How?
		- inspect UV to double-check your thinking
		- determine scaling
		- can use frac to split the UV into segments, to observe coordinates that go beyond 1
		- the result is an absolute coordinate system of the mesh
	2. Determine points within the line segment.
		- Y is constant, always halfway between 0 and 1, aka 0.5
		- X needs some padding, to make the line segment, we clamp the absolute X-values.
		- The dimensions of our mesh is (10, 1). Let's have a padding of 0.5 on each end just like the Y coordinates.
			- This means we want to scale X by 10, start the line at 0.5, and end it at 9.5
	3. Calculate the distance between the absolute UV value and the line segment point
		- That's your SDF!
		- Apply the SDF to the mesh to debug and you can observe the line!
	4. Now we make a mask, and fatten the line by changing the SDF value
		- subtracting SDF by 0.5 will shorten the distance between UV and the edge, fattening the line
		- We want to invert the colors, multiply the SDF by -1
			- this can be combined with the normalization step that scales the SDF by 2
				- this operation of scaling by two brings in the edges toward the line
		- If you want to sharpen it, remember the step function?
		- now you have a mask!
	5. Apply your new mask
		- multiply the output color by your SDF!
	6. To make the border, we add to our SDF to inset from the first SDF
	7. AA is done by getting the fragment's screen space width by using a partial derivative
		- using fwidth() is faster
		- using length(dFdx(borderSDF), dFdy(borderSDF)) is more accurate but slower		
*/

shader_type spatial;
render_mode unshaded;

uniform float current_health : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec4 background_color : hint_color = vec4(0, 0, 0, 1);
uniform sampler2D healthbar_texture : hint_black_albedo, repeat_disable, filter_linear;

uniform float border_size : hint_range(0.0, 0.5, 0.01) = 0.15;

// boundaries where the red/green start most-intensely
uniform float health_boundary_low : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float health_boundary_high : hint_range(0.0, 1.0, 0.01) = 0.8;

void fragment() {
	// create absolute coordinates
	vec2 new_coords = UV;
	new_coords.x *= 10.0;
	
	// calculate point on line
	vec2 point_on_segment = vec2(clamp(new_coords.x, 0.5, 9.5), 0.5);
	
	// calculate distance
	float sdf = distance(new_coords, point_on_segment);

	// manipulate sdf to fit masking needs
	// modify each piece to see what happens!
	sdf *= 2.0;
	sdf -= 1.0;
	
	// if you wanted to do clipping, we do this
	if (-sdf < 0.001) {
		discard;
	}
	// ALBEDO = vec3(sdf, sdf, sdf);
	
	// border
	float borderSDF = sdf + border_size;
	float borderMask = step(0, -borderSDF);
	
	// Anti-aliasing
	float pd = fwidth(borderSDF); // screen space partial derivative (delta distance of screen space for fragment)
	borderMask = 1.0 - clamp(borderSDF / pd, 0.0, 1.0); // chop fragments by delta distance, clamp it, and then invert
	
	// do the healthbar stuff
	vec3 bgColor = background_color.xyz;
	float healthbarMask = 0.0;
	
	healthbarMask = float(current_health > UV.x);
		
	// read from texture
	vec2 sample_coords = vec2(current_health, UV.y);
	vec4 sample = texture(healthbar_texture, sample_coords);
	vec3 outputColor = sample.xyz;
	
	if (current_health < health_boundary_low) {
		// modify outputColor by our flashing behavior
		float frequency = 4.0;
		float amplitude = 0.4;
		float flash = cos(TIME * frequency) * amplitude + 1.0;
		outputColor *= flash;
	}
	
	ALBEDO = outputColor * healthbarMask * borderMask;
}