shader_type canvas_item;

uniform vec4 outline : hint_color = vec4(0, 0, 0, 1);
uniform vec4 cooldown : hint_color = vec4(0, 0, 0, 1);
uniform bool flash = false;

void fragment() {
	vec4 curr_color = texture(TEXTURE,UV);
	
	// flash true => pixels with a non-zero mask turn white
	
	if (flash) {
		if (curr_color.r > 0.0) { // Modif by Ferdi: color.a became color.r
			COLOR = vec4(1.0);
		} else {
			COLOR = curr_color;
		}
	}
	
	// flash false => pixels very close to outline color take cooldown color
	
	else {
		if (distance(curr_color, outline) < 0.01) {
			COLOR = cooldown;
		} else {
			COLOR = curr_color;
		}
	}
}
