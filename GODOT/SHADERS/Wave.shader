//	adapté de http://www.youtube.com/watch?v=SCHdglr35pk

// To apply on a ColorRect!

shader_type canvas_item;

uniform vec2 center; //set to 0.5, 0.5 to be in the center!
uniform float force;
uniform float size;
uniform float thickness;

void fragment(){
	float mask = (1.0 - smoothstep(size - 0.1, size, length(UV - center))) * smoothstep(size - thickness - 0.1, size - thickness, length(UV - center));
	vec2 disp = normalize(UV - center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, UV - disp);
}