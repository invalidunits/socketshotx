shader_type canvas_item;

void fragment() {
	
	vec2 uv = UV;
	uv.x += cos(uv.y+TIME*16.0)*0.05;
	
	
	COLOR = texture(TEXTURE, uv)*COLOR;
	
	
	
	// Place fragment code here.
}