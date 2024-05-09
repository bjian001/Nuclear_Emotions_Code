precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform vec4 u_ScreenParams;
uniform float blurSize;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}


void main() {
    vec2 uv = uv0;
    vec2 screenSize = u_ScreenParams.xy;
    vec2 mySize = screenSize.xy/min(screenSize.x,screenSize.y)*1080.;
    vec2 offset = vec2(0,blurSize)/1080.;
    float weight0 = normpdf(0.0,8.);
    vec4 resultCol = texture2D(inputImageTexture, uv)*weight0;
    float num = weight0;
    for(int i = 1 ;i <= 16 ;i++){
        float j = float(i);
        float tempWeight = normpdf(j,8.);
        resultCol+= texture2D(inputImageTexture, uv+j*offset)*tempWeight;
        resultCol+= texture2D(inputImageTexture, uv-j*offset)*tempWeight;
        num+=2.0*tempWeight;
    }
    resultCol/=num;
    

    gl_FragColor = vec4(resultCol);
    
}