shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
global uniform float tt;
void fragment() {
	// Called for every pixel the material is visible on.
	if(1.0-distance(vec2(0.5,0.5),UV.xy)>tt){
		discard;
	}
	COLOR=vec4(0,0,0,1);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
