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
	float angle=PI-atan(uvCenter.x,uvCenter.y);
	float segmentSize=TAU/6.0;
	int offset=3;
	bool litSeg=segmentSize*float((index+offset)%6)<angle&&segmentSize*float((index+offset)%6+1)>angle;
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
