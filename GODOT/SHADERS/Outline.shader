shader_type canvas_item;

uniform vec4 outline : hint_color = vec4(0, 0, 0, 1);
uniform vec4 cooldown : hint_color = vec4(0, 0, 0, 1);
uniform float mask: hint_range(0.0, 1.0, 0.001) = 1.0;
uniform bool flash = false;

void fragment() {
	vec4 curr_color = texture(TEXTURE,UV);
	if (distance(curr_color, outline) < 0.01) {
		COLOR = cooldown;
	} else if (flash && curr_color.a > 0.0) {
		COLOR = vec4(1);
	} else {
		COLOR = vec4(
			curr_color.r, curr_color.g, curr_color.b, curr_color.a * mask);
	}
}
