shader_type canvas_item;
render_mode blend_mix;

uniform float scale = 0.5;
uniform vec4 recolor = vec4(1.0, 1.0, 1.0, 1.0);

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV);
    
	if (tcol.a == 1.0) {
    	tcol = tcol + (recolor*scale);
	}
    
    COLOR = tcol;
}