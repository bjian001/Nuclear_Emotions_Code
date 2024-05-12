precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform float u_Angle;
uniform float u_Steps;
uniform float u_Sample;
uniform float u_ExpandFlag;
uniform float width;
uniform float height;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}
vec4 gaussianBlur(sampler2D i_InputTex, vec2 i_Uv, vec2 i_Dir)
{
    float sigma = 4.0;
    float weight = normpdf(0.0, sigma);

    vec4 sum            = vec4(0.0);
    vec4 result         = vec4(0.0);
    vec2 unit_uv        = i_Dir * u_Steps;
    float gamma         = 2.2;
    vec4 curColor       = texture2D(i_InputTex, i_Uv);
    vec4 centerPixel    = pow(curColor, vec4(gamma))*weight;
    float sum_weight    = weight;
    // #ifdef GLOWSAMPLE
    float s = u_Sample;
    for(int i=1;i<=1024;i++)
    {
        if (float(i)>u_Sample) break;
        vec2 curRightCoordinate = i_Uv+float(i)*unit_uv;
        vec2 curLeftCoordinate  = i_Uv+float(-i)*unit_uv;
        vec4 rightColor = texture2D(i_InputTex, curRightCoordinate);
        vec4 leftColor = texture2D(i_InputTex, curLeftCoordinate);
        weight = normpdf(float(i) / s * 15.0, sigma);
        sum+=pow(rightColor, vec4(gamma))*weight;
        sum+=pow(leftColor, vec4(gamma))*weight;
        sum_weight+=weight*2.0;
    }
    // #endif
    result = (sum+centerPixel)/sum_weight; 
    result = pow(result, vec4(1.0 / gamma));
    return clamp(result, 0.0, 1.0);
}

void main()
{
    float theta = u_Angle * 3.1415926 / 180.;
     vec2 ratio = (1.0+u_ExpandFlag*0.4) * 720.0 * vec2(width, height) / min(width, height);
    vec2 dir = vec2(cos(theta), sin(theta)) / ratio;
    vec4 color = gaussianBlur(u_InputTex, uv0, dir);
    gl_FragColor = color;
    gl_FragColor.rgb = clamp(gl_FragColor.rgb, 0.0, gl_FragColor.a);
}
