precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;

uniform float threshold1;
uniform float threshold2;
vec2 d0 = vec2(0, 0.015625);
vec2 d1 = vec2(0.016, 0.0126);
// vec2 d2 = vec2(0.026, 0.0048);
vec2 d2 = vec2(0.021, 0.0087);
// vec2 d3 = vec2(0.026, -0.0048);
vec2 d3 = vec2(0.021, -0.0087);
// vec2 d4 = vec2(0.016, -0.0126);
vec2 d5 = vec2(0, -0.015625);
// vec2 d6 = vec2(-0.016, -0.0126);
// vec2 d7 = vec2(-0.026, -0.0048);
vec2 d7 = vec2(-0.021, -0.0087);
// vec2 d8 = vec2(-0.026, 0.0048);
vec2 d8 = vec2(-0.021, 0.0087);
// vec2 d9 = vec2(-0.016, 0.0126);

float cmul(sampler2D tex, vec2 tc)
{
    vec3 c3 = texture2D(tex, tc).rgb;
    return dot(c3, c3) * 0.333;
    // return .2 * c3.r + .7 * c3.g + .1 * c3.b;
}

float stresh(float v, float thresh)
{
    return clamp((v - thresh) * 5.0, 0.0, 1.0);
}

void main()
{
    vec2 tc = uv0;
    float c = stresh(cmul(u_albedo, tc), threshold1);
    // c *= 1.0 - stresh(cmul(u_albedo, tc + d0), treshold2);
    // c *= 1.0 - stresh(cmul(u_albedo, tc + d1), treshold2);
    c *= 1.0 - stresh(cmul(u_albedo, tc + d2), threshold2);
    c *= 1.0 - stresh(cmul(u_albedo, tc + d3), threshold2);
    // c *= 1.0 - stresh(cmul(u_albedo, tc + d4), treshold2);
    // c *= 1.0 - stresh(cmul(u_albedo, tc + d5), treshold2);
    // c *= 1.0 - stresh(cmul(u_albedo, tc + d6), treshold2);
    c *= 1.0 - stresh(cmul(u_albedo, tc + d7), threshold2);
    c *= 1.0 - stresh(cmul(u_albedo, tc + d8), threshold2);
    // c *= 1.0 - stresh(cmul(u_albedo, tc + d9), treshold2);
    vec4 inputColor = texture2D(u_albedo, uv0);
    gl_FragColor = vec4(c, c, c, inputColor.a);
}