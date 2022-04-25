/*
	We use a uniform to import the texture, then sample it using the built-in texture() function at some coords.
	now, then we calculate a t-value for the x-coordinate and that becomes the ALBEDO.
	
	- For texture compression, fiddle with import settings. For other stuff, we can do it in this script.
		- Changed to lossless compression mode
		- I also removed mipmap generation because LOD won't be an issue in this example
	- To disable the texture wrapping, we specify a `repeat_disable` hint for the sampler texture.
		- Wrapping cannot be specified per-axis here.
	- Specifying albedo is important because Godot uses a sRGB-to-linear conversion and renders in linear space.
		- Fancy talk for how a color in an image gets rendered onto the screen. RGB space is different for both sometimes.
	- To change filtering, see hints in reference: 
		https://docs.godotengine.org/en/latest/tutorials/shaders/shader_reference/shading_language.html#uniforms
*/
shader_type spatial;
render_mode unshaded;

uniform float current_health : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec4 background_color : hint_color = vec4(0, 0, 0, 1);
uniform sampler2D healthbar_texture : hint_black_albedo, repeat_disable, filter_linear;

// boundaries where the red/green start most-intensely
uniform float health_boundary_low : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float health_boundary_high : hint_range(0.0, 1.0, 0.01) = 0.8;

void fragment() {
	vec3 bgColor = background_color.xyz;
	float healthbarMask = 0.0;
	
	healthbarMask = float(current_health > UV.x);
		
	// read from texture
	vec2 sample_coords = vec2(current_health, UV.y);
	vec4 sample = texture(healthbar_texture, sample_coords);
	vec3 outputColor = sample.xyz * healthbarMask;
	ALBEDO = outputColor;
}