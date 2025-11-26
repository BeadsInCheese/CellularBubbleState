shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform int index=0;
uniform sampler2D lit;
uniform sampler2D unLit;
void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uvCenter=UV-0.5;
	float angle=PI-atan(uvCenter.x,uvCenter.y) - 0.25;
	float segmentSize=TAU/6.0;
	int offset=3;
	float start = segmentSize*float((index+offset)%6);
	float end = segmentSize*float((index+offset)%6+1);
	bool litSeg=start<angle && end>angle || start<angle+TAU && end>angle+TAU;
	if(litSeg){
		COLOR=texture(lit,UV);
	}else{
		COLOR=texture(unLit,UV);
	}


}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
