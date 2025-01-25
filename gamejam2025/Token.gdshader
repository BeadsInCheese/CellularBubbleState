shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float treshold=1;
void fragment() {
	// Called for every pixel the material is visible on.
	if(UV.y<treshold){
		discard;
	}
	
	float mult=smoothstep(treshold+0.1,treshold,UV.y)*10.;
	COLOR.r=max(mult,COLOR.r);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
