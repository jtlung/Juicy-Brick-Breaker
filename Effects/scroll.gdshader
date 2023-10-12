shader_type canvas_item;


uniform float speed;


void fragment () {
	
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * speed, UV.y))*vec4(.9,.9,.9,1);
}