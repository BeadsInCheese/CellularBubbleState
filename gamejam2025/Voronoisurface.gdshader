shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform sampler2D voronoi;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
void fragment() {
	 vec4 bg_color = texture( SCREEN_TEXTURE, SCREEN_UV );;
	COLOR.a=0.5-abs(0.5-UV.y)-UV.x*UV.x;
if(COLOR.a<0.){
	discard;
}
	vec4 t=max((texture(voronoi,0.01*sin(UV.x*1.*TIME*2.)+fract((UV*(0.02*(UV.x)+1.))-vec2(TIME,0)*0.02))),0);
	if(t.r<0.6){
		discard;
	}
	COLOR=mix(t+10.,bg_color,1.-COLOR.a);


}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
