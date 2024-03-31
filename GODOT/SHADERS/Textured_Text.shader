// Avec l'aide des gens du Discord BabaDesBois


shader_type canvas_item;

uniform sampler2D img;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    if (color.a != 0.0){ 
        COLOR = texture(img, SCREEN_UV);
    } else {
        COLOR = color;
    }
}
