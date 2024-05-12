precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform float u_Angle;
uniform float u_Strength;
uniform float width;
uniform float height;
float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}
vec4 encode(float gray)
{
    vec4 res = vec4(0.0, 0.0, 0.0, 0.0);
    gray *= 255.0;
    res.x = floor(gray) / 255.0;

    gray = fract(gray);
    gray *= 255.0;
    res.y = floor(gray) / 255.0;

    gray = fract(gray);
    gray *= 255.0;
    res.z = floor(gray) / 255.0;

    // gray = fract(gray);
    // gray *= 255.0;
    gray = fract(gray);
    res.w = gray;
    return res;
}
float decode(vec4 g)
{
    float ret = 0.0;
    ret = g.x + g.y / 255.0 + g.z / (65025.0) + g.w / (16581375.0);
    return ret;
}
vec4 gaussianBlur(sampler2D i_InputTex, vec2 i_Uv, vec2 i_Dir, float i_Strength)
{
    const int  radius = 32;
    float s = i_Strength;
    float sigma = 4.0;
    float first = normpdf(0.0, sigma);
    float weight = 0.5 * 1.02 + 0.5;
    weight = first;
    vec4 sum            = vec4(0.0);
    vec4 result         = vec4(0.0);
    vec2 unit_uv        = i_Dir;
    vec4 curColor       = texture2D(i_InputTex, i_Uv);
    float gamma = 2.4;
    float g = decode(curColor);
    // g = curColor.r;
    g = pow(g, gamma);
    float centerg = g * weight;
    float sum_weight    = weight;
    float sumg = 0.0;
    for(float i=1.;i<=1024.;i+=1.0)
    {
        if (i > abs(s)) break;
        vec2 curRightCoordinate = i_Uv+float(i)*unit_uv;
        vec2 curLeftCoordinate  = i_Uv+float(-i)*unit_uv;
        vec4 rightColor = texture2D(i_InputTex, curRightCoordinate);
        vec4 leftColor = texture2D(i_InputTex, curLeftCoordinate);
        float rg = decode(rightColor);
        rg = pow(rg, gamma);
        // rg = rightColor.r;
        float lg = decode(leftColor);
        lg = pow(lg, gamma);
        // lg = leftColor.r;
        // weight = (normpdf(float(i) / s * 15.0, sigma) / first - 0.5) * 1.02 + 0.5;
        weight = normpdf(float(i) / s * 15.0, sigma);
        sumg += (rg + lg) * weight;
        sum_weight+=weight*2.0;
    }
    g = (centerg + sumg) / sum_weight;
    return vec4(pow(g, 1. / gamma));
    // return pow(clamp(result, 0.0, 1.0), vec4(1.0));
}

void main()
{
    float theta = u_Angle * 3.1415926 / 180.;
    vec2 ratio = vec2(720.0) * vec2(width, height) / min(width, height);
    float rescale = min(width, height) / 180.;
    vec2 dir = vec2(cos(theta), sin(theta)) / vec2(width, height);
    vec4 color = gaussianBlur(u_InputTex, uv0, dir, u_Strength * rescale);
    // if (color.x < 0.0)
    // {
    //     color.z = -color.x;
    //     color.x = 0.0;
    // }
    // if (color.y < 0.0)
    // {
    //     color.w = -color.y;
    //     color.y = 0.0;
    // }
    color = encode(color.r);
    gl_FragColor = color;
}
