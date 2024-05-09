precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform int u_BlurR;
uniform float u_Sigma;
uniform vec2 u_Direction;


float getGaussianWeight(int x, float sigma) {
    return exp(-(float(x)*float(x))/(2.0*sigma*sigma));
}

void main()
{
    vec2 pixSum = vec2(0.0);
    float weightSum = 0.0;
    for (int i = -u_BlurR; i <= u_BlurR; i+=1) {
        float weight = getGaussianWeight(i, u_Sigma);
        pixSum += texture2D(u_InputTex, uv0 + float(i) * u_Direction).rg * weight;
        weightSum += weight;
    }
    vec2 res = pixSum / weightSum;
    
    gl_FragColor = vec4(res, 0.0, 1.0);

}
