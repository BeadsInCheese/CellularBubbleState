shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform vec2 offset;
uniform float inner;
uniform float thickness;
uniform vec3 color: source_color;
uniform bool center;
void fragment() {
		COLOR=texture(TEXTURE ,vec2(UV.x,UV.y));
		float dist=length(UV-0.5);
		if(center){
			COLOR=mix(COLOR, vec4(color,float(inner+thickness>dist&&inner<dist)),step(0.5,1.-COLOR.a));
		}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
