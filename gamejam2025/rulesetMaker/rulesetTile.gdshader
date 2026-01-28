shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
		COLOR=texture(TEXTURE ,vec2(UV.x,UV.y));
		COLOR+=vec4(0.,0.,0.,float(0.8<length(UV-0.5)));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
