//	adapté de http://www.youtube.com/watch?v=SCHdglr35pk

shader_type canvas_item;


uniform vec2 center = vec2(0.5, 0.5);
uniform float force: hint_range(-1.0, 1.0, 0.001) = 0.1;
uniform float size: hint_range(-1.0, 1.0, 0.001) = 0.1;
uniform float thickness: hint_range(-1.0, 1.0, 0.001) = 0.1;


void fragment(){
	float mask = (1.0 - smoothstep(size - 0.1, size, length(UV - center))) * smoothstep(size - thickness - 0.1, size - thickness, length(UV - center));
	vec2 disp = normalize(UV - center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, UV - disp);
}