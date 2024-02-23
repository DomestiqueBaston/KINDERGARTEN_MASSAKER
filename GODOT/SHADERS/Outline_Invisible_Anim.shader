//Shader adapté de : https://www.youtube.com/watch?v=zpIjme5Ah7Q

shader_type canvas_item;

uniform vec4 ready : hint_color;
uniform vec4 cooldown : hint_color;
uniform bool flash = false;
uniform float transparency: hint_range(0.0, 1.0, 0.001) = 0.0;



void fragment() {
	vec4 curr_color = texture(TEXTURE,UV); //Get current color of pixel
	
	// flash true => pixels with a non-zero color (was mask) turn white
	
	if (flash) {
		if (curr_color.r > 0.0) { // Modif by Ferdi: color.a became color.r
			COLOR = vec4(1.0);
		} else {
			COLOR = curr_color;
		}
	}
	
	//Let's check that our current pixel color is any of the BLACK_OUTLINEs we wish to swap
	//If our pixel is black then swap BLACK_OUTLINE to RED_OUTLINE.
	if (distance(curr_color, ready) < 0.01)
	{
		COLOR = cooldown;
	}
	else
	{
		//We didn't find any old color for this pixel so keep it it's original color
		COLOR = curr_color;
		//And set the alpha
		if (curr_color.a > 0.0) {
			COLOR.a = transparency;
		}
	}
}

