precision highp float;
varying vec2 uv0;
varying vec2 uv1;

uniform sampler2D inputImageTexture;
uniform sampler2D blendTexture;

uniform int blendMode;
uniform float alphaFactor;
uniform float sizeFactor;

const vec3 C0 = vec3(0.0);
const vec3 C1 = vec3(1.0);
const vec3 C_2 = vec3(0.5);


vec3 rgb2hsl (vec3 RGB) {
    float cmin = min(RGB.r, min(RGB.g, RGB.b));
    float cmax = max(RGB.r, max(RGB.g, RGB.b));
    float C = cmax - cmin;
    float Ceq0 = step(C, 0.0);
    float Cgt0 = 1.0 - Ceq0;

    vec3 H3 = (RGB.gbr - RGB.brg) / (C + Ceq0);
    H3 = (H3 + vec3(0.0, 2.0, 4.0)) / 6.0;

    float L2 = cmax + cmin;
    float L2eq0 = step(L2, 0.0);
    float L2eq2 = step(2.0, L2);

    float H = H3.z;
    float S = mix(C / (L2 + L2eq0), C / (2.0 - L2 + L2eq2), step(1.0, L2));
    float L = L2 * 0.5;

    H = mix(H, H3.y, step(cmax, RGB.g));
    H = mix(H, H3.x, step(cmax, RGB.r));
    H = fract(H);
    H *= Cgt0;
    S *= Cgt0;
    return vec3(H, S, L);
}
vec3 hsl2rgb (vec3 HSL) {
    vec3 P = clamp(abs(mod(HSL.xxx * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return HSL.zzz + HSL.yyy * (P - 0.5) * (1.0 - abs(HSL.z + HSL.z - 1.0));
}


// [Add]
vec3 blend_1001 (vec3 dst, vec3 src) {
    return min(src + dst, C1);
}
// [Average]
vec3 blend_1002 (vec3 dst, vec3 src) {
    return (src + dst) * 0.5;
}
// [Color Burn]
vec3 blend_1003 (vec3 dst, vec3 src) {
    vec3 eq0 = step(C0, -src);
    vec3 res = max(C1 - (C1 - dst) / (src + eq0), C0);
    return mix(res, C0, eq0);
}
// [Color Dodge]
vec3 blend_1004 (vec3 dst, vec3 src) {
    vec3 eq1 = step(C1, src);
    vec3 res = min(dst / (C1 - src + eq1), C1);
    return mix(res, C1, eq1);
}
// [Darken]
vec3 blend_1005 (vec3 dst, vec3 src) {
    return min(src, dst);
}
// [Difference]
vec3 blend_1006 (vec3 dst, vec3 src) {
    return abs(dst - src);
}
// [Exclusion]
vec3 blend_1007 (vec3 dst, vec3 src) {
    vec3 mul = dst * src;
    return dst + src - (mul + mul);
}
// [Glow]
vec3 blend_1008 (vec3 dst, vec3 src) {
    vec3 eq1 = step(C1, dst);
    vec3 res = min(src * src / (C1 - dst + eq1), C1);
    return mix(res, C1, eq1);
}
// [Hard Light]
vec3 blend_1009 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, dst);
    vec3 res0 = dst * src;
    res0 += res0;
    vec3 res1 = (C1 - dst) * (C1 - src);
    res1 = C1 - res1 - res1;
    return mix(res0, res1, ge_2);
}
// [Hard Mix]
vec3 blend_1010 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, src);
    vec3 res0 = blend_1003(dst, (src + src));
    res0 = mix(C0, C1, step(C_2, res0));
    vec3 res1 = blend_1004(dst, (src + src) - C1);
    res1 = mix(C0, C1, step(C_2, res1));
    return mix(res0, res1, ge_2);
}
// [Lighten]
vec3 blend_1011 (vec3 dst, vec3 src) {
    return max(dst, src);
}
// [Linear Burn]
vec3 blend_1012 (vec3 dst, vec3 src) {
    return max(dst + src - C1, C0);
}
// [Linear Dodge]
vec3 blend_1013 (vec3 dst, vec3 src) {
    return min(dst + src, C1);
}
// [Linear Light]
vec3 blend_1014 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, src);
    vec3 res0 = blend_1012(dst, (src + src));
    vec3 res1 = blend_1013(dst, (src + src) - C1);
    return mix(res0, res1, ge_2);
}
// [Multiply]
vec3 blend_1015 (vec3 dst, vec3 src) {
    return dst * src;
}
// [Negation]
vec3 blend_1016 (vec3 dst, vec3 src) {
    return C1 - abs(C1 - dst - src);
}
// [Overlay]
vec3 blend_1017 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, dst);
    vec3 res0 = dst * src;
    res0 += res0;
    vec3 res1 = (C1 - dst) * (C1 - src);
    res1 = C1 - res1 - res1;
    return mix(res0, res1, ge_2);
}
// [Phoenix]
vec3 blend_1018 (vec3 dst, vec3 src) {
    return C1 + min(dst, src) - max(dst, src);
}
// [Pin Light]
vec3 blend_1019 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, src);
    vec3 res0 = blend_1005(dst, (src + src));
    vec3 res1 = blend_1011(dst, (src + src) - C1);
    return mix(res0, res1, ge_2);
}
// [Reflect]
vec3 blend_1020 (vec3 dst, vec3 src) {
    return blend_1008(src, dst);
}
// [Screen]
vec3 blend_1021 (vec3 dst, vec3 src) {
    return C1 - (C1 - dst) * (C1 - src);
}
// [Soft Light]
vec3 blend_1022 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, src);
    vec3 dst2 = dst + dst;
    vec3 src2 = src + src;
    vec3 res0 = dst2 * src + dst * dst * (C1 - src2);
    vec3 res1 = sqrt(dst) * (src2 - C1) + dst2 * (C1 - src);
    return mix(res0, res1, ge_2);
}
// [Subtract]
vec3 blend_1023 (vec3 dst, vec3 src) {
    return max(dst + src - C1, C0);
}
// [Vivid Light]
vec3 blend_1024 (vec3 dst, vec3 src) {
    vec3 ge_2 = step(C_2, src);
    vec3 res0 = blend_1003(dst, (src + src));
    vec3 res1 = blend_1004(dst, (src + src) - C1);
    return mix(res0, res1, ge_2);
}
// [Snow Hue]
vec3 blend_1025 (vec3 dst, vec3 src) {
    dst = rgb2hsl(dst);
    src = rgb2hsl(src);
    vec3 res = vec3(src.x, dst.y, dst.z);
    return hsl2rgb(res);
}
// [Snow Saturation]
vec3 blend_1026 (vec3 dst, vec3 src) {
    dst = rgb2hsl(dst);
    src = rgb2hsl(src);
    vec3 res = vec3(dst.x, src.y, dst.z);
    return hsl2rgb(res);
}


vec3 unpremultiply (vec3 color, float alpha) {
    return color / (alpha + 0.0001);
}

vec4 blend (int mode, vec4 dst, vec4 src) {
    if (mode == 0)
        return src + dst * (1.0 - src.a);
    vec3 d = unpremultiply(dst.rgb, dst.a);
    vec3 s = unpremultiply(src.rgb, src.a);
    if (mode == 1001)
        s = blend_1001(d, s);
    else if (mode == 1002)
        s = blend_1002(d, s);
    else if (mode == 1003)
        s = blend_1003(d, s);
    else if (mode == 1004)
        s = blend_1004(d, s);
    else if (mode == 1005)
        s = blend_1005(d, s);
    else if (mode == 1006)
        s = blend_1006(d, s);
    else if (mode == 1007)
        s = blend_1007(d, s);
    else if (mode == 1008)
        s = blend_1008(d, s);
    else if (mode == 1009)
        s = blend_1009(d, s);
    else if (mode == 1010)
        s = blend_1010(d, s);
    else if (mode == 1011)
        s = blend_1011(d, s);
    else if (mode == 1012)
        s = blend_1012(d, s);
    else if (mode == 1013)
        s = blend_1013(d, s);
    else if (mode == 1014)
        s = blend_1014(d, s);
    else if (mode == 1015)
        s = blend_1015(d, s);
    else if (mode == 1016)
        s = blend_1016(d, s);
    else if (mode == 1017)
        s = blend_1017(d, s);
    else if (mode == 1018)
        s = blend_1018(d, s);
    else if (mode == 1019)
        s = blend_1019(d, s);
    else if (mode == 1020)
        s = blend_1020(d, s);
    else if (mode == 1021)
        s = blend_1021(d, s);
    else if (mode == 1022)
        s = blend_1022(d, s);
    else if (mode == 1023)
        s = blend_1023(d, s);
    else if (mode == 1024)
        s = blend_1024(d, s);
    else if (mode == 1025)
        s = blend_1025(d, s);
    else if (mode == 1026)
        s = blend_1026(d, s);
    else
        s = d;
    return vec4(mix(d, s, src.a), 1.0) * dst.a;
}


void main(void) 
{
    vec4 base = texture2D(inputImageTexture, uv0);
    vec4 src1 = texture2D(blendTexture, uv1);
    base = blend(1009, base, src1 * alphaFactor);
    gl_FragColor = base;

//    vec2 uv1 = vec2(uv0.x,1.0-uv0.y);
//    uv1 -= 0.5;
//    uv1 *= sizeFactor;
//    uv1 += 0.5;
//    vec4 fgColor = texture2D(blendTexture, uv1);
//    fgColor = fgColor * alphaFactor;
//
//    int newBlendMode = blendMode;
//    if (newBlendMode >= 1000) {
//        newBlendMode = newBlendMode - 1000;
//    }
//    vec4 bgColor = texture2D(inputImageTexture, uv0);
//    vec3 color = blendFunc(bgColor.rgb, clamp(fgColor.rgb * (1.0 / fgColor.a), 0.0, 1.0), 1.0,newBlendMode);
//    gl_FragColor = vec4(bgColor.rgb * (1.0 - fgColor.a) + color.rgb * fgColor.a, 1.0);
}
