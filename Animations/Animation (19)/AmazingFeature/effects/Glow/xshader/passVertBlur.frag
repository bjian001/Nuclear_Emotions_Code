precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTexture;
uniform sampler2D u_albedo;
uniform float vertR;
uniform vec4 u_ScreenParams;
uniform vec3 ColorA;
uniform vec3 ColorB;
uniform float sigma;
uniform float intensity;
uniform float threshold;
uniform float flagGlowColor;

vec4 neighborColor(float i){
	float blurSize=1.;
	vec2 unit=vec2(blurSize/u_ScreenParams.x,blurSize/u_ScreenParams.y);
	vec2 uv1 = uv0 + unit * vec2(0., i);
	vec2 uv2 = uv0 - unit * vec2(0., i);
	vec4 result = texture2D(inputTexture, uv1) * step(uv1.y, 1.) * step(0., uv1.y)
				+ texture2D(inputTexture, uv2) * step(uv2.y, 1.) * step(0., uv2.y);
	return result;
}

float Gaussian (float x)
{
    return exp(-(x*x) / (2.0 * sigma*sigma * vertR * vertR / 100.)) * 10.;
}

vec4 vertBlurColor(vec4 curColor){
	vec4 resultColor=vec4(0.);
	vec4 centerPixel=curColor*10.;
	resultColor += centerPixel;
	float weight=10.;
	float w = 0.;
	float nsamples = 8. * (vertR / 10.);
	for(float i=1.;i<=128.;i++){
		if(i>nsamples){
			break;
		}
		w = Gaussian(float(i));
		resultColor+=neighborColor(i) * w;
		weight+= w * 2.;
	}
	resultColor /= weight;
	return resultColor;
}

void main()
{
	vec4 inputColor = texture2D(u_albedo, uv0);
	vec4 curColor=texture2D(inputTexture,uv0);
	vec4 resultColor = vertBlurColor(curColor);
	// resultColor = adjustColor(resultColor);

	// resultColor.rgb += inputColor.rgb;

	gl_FragColor=resultColor;

}
