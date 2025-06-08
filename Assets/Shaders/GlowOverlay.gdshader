shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform bool highlight_enabled = false;
uniform vec4 highlight_color : source_color = vec4(0, 1.0, 1.0, 0.1);

void fragment() {
	vec4 base = texture(albedo_texture, UV);
	vec3 final_color = base.rgb;

	if (highlight_enabled) {
		final_color = mix(final_color, highlight_color.rgb, highlight_color.a);
	}

	ALBEDO = final_color;
}