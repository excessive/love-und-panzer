vec3 correct_gamma(in vec3 color) {
	const float gamma = 2.2;
	return pow(color, vec3(1.0 / gamma));
}

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords) {
	vec3 out_color = correct_gamma(texture2D(texture, texture_coords).rgb);
	return vec4(out_color, dot(out_color.rgb, vec3(0.299, 0.587, 0.114))); // for FXAA
}
