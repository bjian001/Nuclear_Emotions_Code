precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform sampler2D u_GlowBlurTex1;
uniform sampler2D u_GlowBlurTex2;
uniform sampler2D u_GlowBlurTex3;
uniform sampler2D u_GlowBlurTex4;
uniform sampler2D u_GlowBlurTex5;
uniform sampler2D u_GlowBlurTex6;
uniform sampler2D u_GlowBlurTex7;
uniform sampler2D u_GlowBlurTex8;
uniform float u_GlowIntensity;
uniform float satFactor;
// uniform vec4 u_TextColor;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z +  (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    vec4 oriColor = texture2D(u_InputTex, uv0);
    vec4 blurColor1 = texture2D(u_GlowBlurTex1, uv0);
    vec4 blurColor2 = texture2D(u_GlowBlurTex2, uv0);
    vec4 blurColor3 = texture2D(u_GlowBlurTex3, uv0);
    vec4 blurColor4 = texture2D(u_GlowBlurTex4, uv0);
    vec4 blurColor5 = texture2D(u_GlowBlurTex5, uv0);
    vec4 blurColor6 = texture2D(u_GlowBlurTex6, uv0);
    vec4 blurColor7 = texture2D(u_GlowBlurTex7, uv0);
    vec4 blurColor8 = texture2D(u_GlowBlurTex8, uv0);
    float intensity = pow(u_GlowIntensity * 0.5, 1./2.4);
    vec4 dis1 = clamp(blurColor1 * intensity * .25, 0.0, 1.0);
    vec4 dis2 = clamp(blurColor2 * intensity * .5, 0.0, 1.0);
    vec4 dis3 = clamp(blurColor3 * intensity * .75, 0.0, 1.0);
    vec4 dis4 = clamp(blurColor4 * intensity * 1., 0.0, 1.0);
    vec4 dis5 = clamp(blurColor5 * intensity * 1.25, 0.0, 1.0);
    vec4 dis6 = clamp(blurColor6 * intensity * 1.5, 0.0, 1.0);
    vec4 dis7 = clamp(blurColor7 * intensity * 1.75, 0.0, 1.0);
    vec4 dis8 = clamp(blurColor8 * intensity * 2., 0.0, 1.0);
    dis1 = 1. - (1. - dis1) * (1. - dis2);
    dis1 = 1. - (1. - dis1) * (1. - dis3);
    dis1 = 1. - (1. - dis1) * (1. - dis4);
    dis1 = 1. - (1. - dis1) * (1. - dis5);
    dis1 = 1. - (1. - dis1) * (1. - dis6);
    dis1 = 1. - (1. - dis1) * (1. - dis7);
    dis1 = 1. - (1. - dis1) * (1. - dis8);

    vec4 disN = (1. - (1. - dis1 * intensity) * (1. - dis1));
    // disN = (1. - (1. - dis1 * intensity) * (1. - disN));
    vec4 glowColor = clamp(vec4(disN) * intensity / .65, 0.0, 1.0);
    // vec4 glowColor = clamp(vec4(dis1) * max(0., 1.0), 0.0, 1.0);
    oriColor = (1. - (1. - glowColor) * (1. - oriColor));
    oriColor.rgb = rgb2hsv(oriColor.rgb);
    oriColor.g *= 1. + intensity * .2;
    // oriColor.b *= 1. + intensity * .2;
    oriColor.rgb = hsv2rgb(oriColor.rgb);
    oriColor.rgb = clamp(oriColor.rgb, 0., oriColor.a);
    // oriColor.rgb = mix(vec4(0), oriColor, oriColor.a).rgb;
    // oriColor.a = 1.;
    gl_FragColor = oriColor;
}
