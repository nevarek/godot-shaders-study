/*
	- Adding and subtracting so that values go into negative creates an SDF, that's what pretty much that defines them.
	- The applications of having signed distance and area are what is really powerful.
	- Consider using a texture to make development (and shader) faster.
	- The capsule shape needed for the healthbar is a distance from a line segment.
*/
shader_type spatial;
render_mode unshaded;

float sdEllipsoid( vec3 p, vec3 r ) {
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

void fragment() {
	vec2 point = vec2(0, 0);
	
	// 
	// negative values = inside circle
	float dist = length(-0.5+UV) - 0.2;
	// dist = step(0, dist); // threshold check
	
	// linear distance field
	dist = UV.x - 0.2;
	
	//ALBEDO = vec3(-0.5+UV.x, 0.5-UV.y, 0);
	ALBEDO = vec3(dist, dist, dist);
	
	// ALBEDO *= sdEllipsoid(vec3(0,0,0), vec3(1, 1, 1));
}