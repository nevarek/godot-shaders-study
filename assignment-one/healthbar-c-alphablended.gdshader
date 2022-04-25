/* notes on alpha blending (you can skip to 6 for the tldr)
	1. Alpha blended shaders should not render opaque, because they are going to write to the depth buffer.
		Other shader code will depend on what's written to the depth buffer, so if you draw the transparent pixel it will
		be as if you are occluding something, but no pixels will be drawn.
	2. In Godot, we want the `depth_draw_opaque` setting, ironically named, as it will make sure
		transparent pixels are not added to the depth buffer.
	3. Godot depth drawing is aggressively ignored for alpha values. There are checks for discarded pixels and
		ALPHA value being modified at any point, where the shader is brought to the alpha pipeline automatically.
		Trying to replicate the broken behavior discussed in the video is difficult to create (and leaves us with
		no way to observe a true fail/unintended state).
	4. The general formula for blend modes is:
			`src_fragment * X + dst_fragment * Y`
		- src is this fragment, dst is the existing color/fragment from the depth buffer
		- alpha blending formula specifically is `src * srcAlpha + dst * (1 - srcAlpha)` which is a lerpy function
	5. Premultiply alpha blending exists, and is its own method.
	6. The alpha blend is as simple as modifying `ALPHA` directly: the code at timestamp 38:00 is simply `ALPHA = UV.x` for us.
		This value is independent from `ALBEDO`, which is our fragment's "color".
*/
shader_type spatial;
render_mode unshaded, depth_draw_opaque;

uniform float current_health : hint_range(0.0, 1.0, 0.01) = 0.5;

// boundaries where the red/green start most-intensely
uniform float health_boundary_low : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float health_boundary_high : hint_range(0.0, 1.0, 0.01) = 0.8;

float inverse_lerp(in float a, in float b, in float value) {
	return (value - a) / (b - a);
}

void fragment() {
	float healthbarMask = 0.0;
	
	healthbarMask = float(current_health > UV.x);

	float t_health = inverse_lerp(health_boundary_low, health_boundary_high, current_health);
	t_health = clamp(t_health, 0, 1);
	
	vec3 healthbarColor = mix(vec3(1, 0, 0), vec3(0, 1, 0), t_health);
	vec3 outputColor = healthbarColor;
	ALBEDO = outputColor;
	ALPHA = healthbarMask;
}