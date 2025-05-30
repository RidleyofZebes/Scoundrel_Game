shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float blur_strength = 2.0;
uniform vec2 screen_size;


void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 sum = vec4(0.0);
	
	// Simple Gaussian blur
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
vec2 offset = vec2(float(x), float(y)) * blur_strength / screen_size;
			sum += texture(screen_texture, uv + offset);
		}
	}

	sum /= 25.0; // 5x5 kernel
	COLOR = sum;
}
