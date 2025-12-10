shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float treshold=1;
uniform vec3 color;
uniform int type;
uniform float angle;
uniform float highlight;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D NOISE_PATTERN2;
uniform float offset;
void fragment() {
	// Called for every pixel the material is visible on.
	if(UV.y<treshold){
		discard;
	}

	float mult=smoothstep(treshold+0.1,treshold,UV.y)*6.;
	if(mult>3.){
		COLOR=vec4(color*mult,COLOR.a);
	}
	if(type==1||type==3){
		//COLOR=COLOR+0.3*vec4(color,COLOR.a)*abs(sin(sin(UV.x*20.)+TIME*1.+UV.y*32.));
	}else{
		float t = TIME/48.0+offset;
		t=fract(t)*2.-1.;
		vec2 kx=vec2(sin(angle),cos(angle));
		vec2 start=t*20.*normalize(vec2(kx.y,-kx.x));
		float d=1.-(length(UV-0.5));

		vec2 line=start+kx;
		float dl=length((start-UV)-(start-line)*(dot(start-line,start-UV)/dot(start-line,start-line)))-0.1;
		float dist=clamp(0.15*max(-d*d,(1.-d))+0.6*dl,0.,1.);
		float v=1.-smoothstep(0.0,0.10,dist);//+clamp(step(0.99,sin(UV.x+UV.y+TIME)),0.,1.);
		COLOR=0.9*highlight*vec4(COLOR*(1.-v))+(type==2?vec4(0.6,1.8,1.9,COLOR.a):vec4(1.6,0.9,0.8,COLOR.a))*v;
	}
	if(type==1 || type==3){
	float n1=texture(NOISE_PATTERN2,vec2(fract(UV.x+TIME/10.+offset),fract(UV.y))).r;
	float n2=texture(NOISE_PATTERN2,vec2(fract(UV.x-TIME/10.+offset),fract(UV.y))).r;
	float n3=texture(NOISE_PATTERN2,vec2(fract(UV.x+offset),fract(UV.y+TIME/20.))).r;
	float n4=texture(NOISE_PATTERN2,vec2(fract(UV.x+offset),fract(UV.y-TIME/20.))).r;
	COLOR=highlight*mix(COLOR,vec4(vec3(0.6,1.0,0.6)+color,COLOR.a),clamp(n2*n1*n3*n4,0,1));

	}else{
	float n1=texture(NOISE_PATTERN,vec2(fract(UV.x+TIME/10.+offset),fract(UV.y))).r;
	float n2=texture(NOISE_PATTERN,vec2(fract(UV.x-TIME/10.+offset),fract(UV.y))).r;
	COLOR=mix(COLOR,vec4(vec3(0.6,1.0,0.6)+color,COLOR.a),clamp(n2*n2*n1*n1,0,1));
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
