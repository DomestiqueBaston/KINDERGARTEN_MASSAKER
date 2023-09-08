//Shader adapté de : https://www.youtube.com/watch?v=zpIjme5Ah7Q

shader_type canvas_item;

uniform vec4 ready : hint_color;
uniform vec4 cooldown : hint_color;



void fragment() {
	vec4 curr_color = texture(TEXTURE,UV); //Get current color of pixel
	
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
		COLOR.a = 0.0;
	}
}

