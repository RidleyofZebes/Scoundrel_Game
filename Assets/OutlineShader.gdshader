shader_type spatial;
render_mode cull_disabled;

uniform float outline_width = 0.05;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.5, 1.0); // Yellow

void vertex() {
	VERTEX += NORMAL * outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	EMISSION = outline_color.rgb;
}
