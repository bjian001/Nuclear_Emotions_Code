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
uniform float u_gamma;
uniform int u_blendType;
void main()
{

    float gamma = u_gamma;
    vec4 oriColor = texture2D(u_InputTex, uv0);
    vec4 blurColor1 = texture2D(u_GlowBlurTex1, uv0);
    vec4 blurColor2 = texture2D(u_GlowBlurTex2, uv0);
    vec4 blurColor3 = texture2D(u_GlowBlurTex3, uv0);
    vec4 blurColor4 = texture2D(u_GlowBlurTex4, uv0);
    vec4 blurColor5 = texture2D(u_GlowBlurTex5, uv0);
    vec4 blurColor6 = texture2D(u_GlowBlurTex6, uv0);
    vec4 blurColor7 = texture2D(u_GlowBlurTex7, uv0);
    vec4 blurColor8 = texture2D(u_GlowBlurTex8, uv0);
    float intensity = u_GlowIntensity;
    vec4 dis1 = clamp(blurColor1 * intensity, 0.0, 1.0);
    vec4 dis2 = clamp(blurColor2 * intensity, 0.0, 1.0);
    vec4 dis3 = clamp(blurColor3 * intensity, 0.0, 1.0);
    vec4 dis4 = clamp(blurColor4 * intensity, 0.0, 1.0);
    vec4 dis5 = clamp(blurColor5 * intensity, 0.0, 1.0);
    vec4 dis6 = clamp(blurColor6 * intensity, 0.0, 1.0);
    vec4 dis7 = clamp(blurColor7 * intensity, 0.0, 1.0);
    vec4 dis8 = clamp(blurColor8 * intensity, 0.0, 1.0);
    dis1 = pow(dis1, vec4(gamma));
    dis2 = pow(dis2, vec4(gamma));
    dis3 = pow(dis3, vec4(gamma));
    dis4 = pow(dis4, vec4(gamma));
    dis5 = pow(dis5, vec4(gamma));
    dis6 = pow(dis6, vec4(gamma));
    dis7 = pow(dis7, vec4(gamma));
    dis8 = pow(dis8, vec4(gamma));

    vec4 glowColor = vec4(0.0);
    if (u_blendType == 0) {
        dis1 = 1. - (1. - dis1) * (1. - dis2);
        dis1 = 1. - (1. - dis1) * (1. - dis3);
        dis1 = 1. - (1. - dis1) * (1. - dis4);
        dis1 = 1. - (1. - dis1) * (1. - dis5);
        dis1 = 1. - (1. - dis1) * (1. - dis6);
        dis1 = 1. - (1. - dis1) * (1. - dis7);
        dis1 = 1. - (1. - dis1) * (1. - dis8);
        glowColor = pow(dis1, vec4(1.0/gamma));
        oriColor = (1. - (1. - glowColor) * (1. - oriColor));
    }
    else {
        dis1 = dis1 + dis2;
        dis1 = dis1 + dis3;
        dis1 = dis1 + dis4;
        dis1 = dis1 + dis5;
        dis1 = dis1 + dis6;
        dis1 = dis1 + dis7;
        dis1 = dis1 + dis8;
        glowColor = pow(dis1, vec4(1.0/gamma));
        oriColor = glowColor + oriColor;
    }
    gl_FragColor = oriColor;
}
