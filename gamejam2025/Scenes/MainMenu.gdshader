shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y+=sin(TIME+UV.x*20.)*20.;
}
void fragment() {
	//float t=UV.y+0.004*sin(TIME+UV.x*3.);
	//COLOR=texture(TEXTURE ,vec2(UV.x,t));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
