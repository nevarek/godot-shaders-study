shader_type spatial;

/*
	Take a look at the Godot documentation for `render_mode` options like:
		- cull_front, cull_back
		
*/
render_mode unshaded;
render_mode depth_draw_never;
render_mode blend_mul;  


void fragment() {
	int numRepeats = 5;
	float yOffset = sin(-UV.x * TAU * 8.0) * 0.01;
	float t = cos((UV.y + yOffset + TIME * 0.1) * TAU * float(numRepeats)) * 0.5 + 0.5;
	t *= UV.y - 0.1 ;
	ALBEDO = vec3(t, t, t);
	
	EMISSION = vec3(1, 1, 1);
}