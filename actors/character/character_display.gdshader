shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float cloak: hint_range(0.0, 1.0, 0.1);
uniform int outline_detail: hint_range(0, 8, 1);
uniform float outline_size: hint_range(0.0, 50.0);
uniform vec4 outline_color: source_color = vec4(1);



varying vec2 direction;
varying vec2 size;

void vertex() {
	size = TEXTURE_PIXEL_SIZE;

	direction = mat3(MODEL_MATRIX)[0].xy;
}


void fragment() {
	vec2 uv = SCREEN_UV;

	uv += direction * (sin(((TIME*4.0) + UV.y*24.0))*0.005)*cloak;








	vec4 c = textureLod(screen_texture, uv, 0.0);
	COLOR *= c;

	float outline_alpha = float(-outline_detail) * COLOR.a;
	int outline_det = max(outline_detail, 1)*4;


	for (int i = 0; i < outline_det; i++) {
		vec2 offset = vec2(
			cos(float(i)*TAU/float(outline_det)),
			sin(float(i)*TAU/float(outline_det))
		)*outline_size*size;
		outline_alpha += texture(screen_texture, uv + offset).a;
	}
	outline_alpha = min(outline_alpha, 1.0);


	COLOR = mix(COLOR, outline_color, min(outline_alpha, 1.0)-COLOR.a);
	COLOR.a *= max(0.05, 1.0-cloak);
}
