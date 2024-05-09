precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTexture;
uniform sampler2D u_albedo;
uniform float horzR;
uniform vec4 u_ScreenParams;
uniform float sigma;

vec4 neighborColor(float i){
	float blurSize=1.;
	vec2 unit=vec2(blurSize/u_ScreenParams.x,blurSize/u_ScreenParams.y);
	vec2 uv1 = uv0 + unit * vec2(i, 0.);
	vec2 uv2 = uv0 - unit * vec2(i, 0.);
	vec4 result = texture2D(inputTexture, uv1) * step(uv1.x, 1.) * step(0., uv1.x)
				+ texture2D(inputTexture, uv2) * step(uv2.x, 1.) * step(0., uv2.x);
	return result;
}

float Gaussian (float x)
{
	// multiply 10 to alleviate precision problem
    return exp(-(x*x) / (2.0 * sigma*sigma * horzR * horzR / 100.)) * 10.; 
}

vec4 horzBlurColor(vec4 curColor){
	vec4 resultColor=vec4(0.);
	
	vec4 centerPixel=curColor*10.;
	resultColor += centerPixel;
	float weight=10.;
	float i = 1.;
	float w = 0.;
	float nsamples = 8. * (horzR / 10.);
	for(float i=1.;i<=128.;i++){
		if(i>nsamples){
			break;
		}
		w = Gaussian(float(i));
		resultColor += neighborColor(i) * w;
		weight += w * 2.;
	}
	resultColor /= weight;
	return resultColor;
}

void main()
{
	vec4 curColor=texture2D(inputTexture,uv0);
	gl_FragColor=horzBlurColor(curColor);
}
