precision highp float;
varying highp vec2 uv0;
uniform float threshold;
uniform sampler2D u_albedo;
uniform float flagGlowColor;

float rgb2grey(vec3 rgbColor){
    return (rgbColor.r*0.299 + rgbColor.g*0.587 + rgbColor.b*0.114);
}

vec3 selfGlowColor(vec4 curColor) {
	vec4 resultColor=curColor;
	float t=clamp(threshold,.01,1.);
	resultColor.rgb=smoothstep(t - .065 * threshold,t+.065,resultColor.rgb);
	float gamma = 2.2;
	return pow(resultColor.rgb, vec3(1. / gamma));
}

vec3 abGlowColor(vec4 curColor){
	float t = clamp(threshold, .01, 1.);
	float grey = rgb2grey(curColor.rgb);
	vec3 resultColor = smoothstep(t - .065 * threshold, t + .065, vec3(grey)); 
	return resultColor;
}

vec4 highlightColor(vec4 curColor){
	vec4 SelfGlowColor=curColor;
	SelfGlowColor.rgb = selfGlowColor(curColor);

	
	vec4 sourceColor = curColor;
	sourceColor.rgb = abGlowColor(curColor);
	
	vec4 ABColor = sourceColor;
	vec4 ABAColor = sourceColor;
	vec4 resultColor = vec4(0.);
	if (flagGlowColor < .5) resultColor = SelfGlowColor;
	else if (flagGlowColor < 1.5) resultColor = ABColor;
	else resultColor = ABAColor;
	return resultColor;
}

void main()
{
	vec4 curColor=texture2D(u_albedo,uv0);
	gl_FragColor= highlightColor(curColor);
}
