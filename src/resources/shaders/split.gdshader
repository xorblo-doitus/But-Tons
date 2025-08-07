shader_type canvas_item;

uniform float horizontal_split_pixel : hint_range(0, 64, 1) = 8;
uniform float vertical_split_pixel : hint_range(0, 64, 1) = 8;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


// RYM
// YGC
// MCB


vec4 screenTexture(vec2 pos) {
	return textureLod(screen_texture, pos, 0.0);
}


void fragment() {
	float horizontal_split_uv = horizontal_split_pixel * SCREEN_PIXEL_SIZE.x;
	float vertical_split_uv = vertical_split_pixel * SCREEN_PIXEL_SIZE.y;

    COLOR.r = (
		screenTexture(SCREEN_UV + vec2(horizontal_split_uv, vertical_split_uv)).r / 3.0
		+ screenTexture(SCREEN_UV + vec2(horizontal_split_uv, 0)).r / 6.0
		+ screenTexture(SCREEN_UV + vec2(0, vertical_split_uv)).r / 6.0
		+ screenTexture(SCREEN_UV + vec2(horizontal_split_uv, -vertical_split_uv)).r / 6.0
		+ screenTexture(SCREEN_UV + vec2(-horizontal_split_uv, vertical_split_uv)).r / 6.0
	);

    COLOR.g = (
		screenTexture(SCREEN_UV).g / 3.0
		+ screenTexture(SCREEN_UV + vec2(horizontal_split_uv, 0)).g / 6.0
		+ screenTexture(SCREEN_UV + vec2(0, vertical_split_uv)).g / 6.0
		+ screenTexture(SCREEN_UV + vec2(-horizontal_split_uv, 0)).g / 6.0
		+ screenTexture(SCREEN_UV + vec2(0, -vertical_split_uv)).g / 6.0
	);

    COLOR.b = (
		screenTexture(SCREEN_UV - vec2(horizontal_split_uv, vertical_split_uv)).b / 3.0
		+ screenTexture(SCREEN_UV - vec2(horizontal_split_uv, 0)).b / 6.0
		+ screenTexture(SCREEN_UV - vec2(0, vertical_split_uv)).b / 6.0
		+ screenTexture(SCREEN_UV - vec2(horizontal_split_uv, -vertical_split_uv)).b / 6.0
		+ screenTexture(SCREEN_UV - vec2(-horizontal_split_uv, vertical_split_uv)).b / 6.0
	);
	//COLOR.a = 1.0;
	//COLOR.rg = vec2(SCREEN_PIXEL_SIZE.x, vertical_split_uv);
}