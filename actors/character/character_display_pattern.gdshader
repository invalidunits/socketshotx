shader_type canvas_item;

uniform sampler2D pattern:hint_default_transparent;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = COLOR*texture(TEXTURE, UV);
	vec4 color_pattern = texture(pattern, UV);
	COLOR = vec4(mix(COLOR.rgb, color_pattern.rgb, color_pattern.a), COLOR.a);
}
