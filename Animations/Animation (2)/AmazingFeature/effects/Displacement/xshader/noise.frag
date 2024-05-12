precision highp float;
varying highp vec2 uv0;

uniform float u_Complexity;
uniform float u_Evolution;
uniform float u_Cycle;
uniform float width;
uniform float height;

uniform vec2 u_Scale;
uniform vec2 u_Offset;
uniform float u_Rotate;
uniform float u_SubImpact;
uniform float u_SubScale;
uniform float u_SubRotate;
uniform vec2 u_SubOffset;
uniform float u_type;


#define PI 3.1415926
#define HASHSCALE3 vec3(.8031, .1030, .3973)
float hash21(vec2 p){
    vec2 p2 = fract(p*1324.518);
    p2+=dot(p2,p2.yx+22.541);
    return fract((p2.x+p2.y)*p2.y);
}

vec2 vec4ToVec2(vec4 val) {
    float a = val.x + val.y/255.0;
    float b = val.z + val.w/255.0;
    return vec2(a, b);
}
vec4 vec2ToVec4(vec2 val) {
    float a = floor(val.x*255.0)/255.0;
    float b = fract(val.x*255.0);
    float c = floor(val.y*255.0)/255.0;
    float d = fract(val.y*255.0);
    return vec4(a, b, c, d);
}

vec2 random2(vec2 p, vec2 seed){

    float n = hash21((p.xy));
    float n2 = 4.412;
    float evol = seed.x + n;
    float evol0 = floor(evol);
    float evol1 = evol0+1.0;
    if(u_Cycle >= 2.0)
    {
        evol0 = floor(mod(evol, u_Cycle));
        evol1 = floor(mod(evol+1.0, u_Cycle));
    }
    vec2 p2 = fract((p.xy)*(34.532+evol0*n2 + (seed.y) * HASHSCALE3.x));
    p2+=dot(p2,p2.yx+15.434);
    vec2 result1 = fract((p2.xy+p2.yx + 0.523)*p2.yx+n);

    vec2 p22 = fract((p.xy)*(34.532+evol1*n2 + (seed.y) * HASHSCALE3.x));
    p22+=dot(p22,p22.yx+15.434);
    vec2 result2 = fract((p22.xy+p22.yx + 0.523)*p22.yx+n);

    float w = fract(evol);
    // w = 1.6 * w - 0.6*w * w * w * (w * (w * 6.0 - 15.0) + 10.0);
    // w = smoothstep(0.0, 1.0, w);
    // w = sign(w-0.5)*(2.*w-1.)*(2.*w-1.)*0.5+0.5;
    // w = sign(w-0.5) * pow(abs(w-0.5)*2., 1.2)*0.5+0.5;

    return mix(result1, result2, w) * 2.0 - 1.0;
    // return  vec2(n);
}

vec2 rotate(vec2 uv, float theta)
{
    uv.y *= height / width;
    float sint = sin(theta);
    float cost = cos(theta);
    mat2 rot = mat2(
        cost, sint,
        -sint, cost
    );
    uv -= 0.5;
    uv = rot * uv;
    uv += 0.5;
    uv.y *= width / height;
    return uv;
}


float interpolation(vec2 uv, vec2 seed)
{
    vec2 ratio = vec2(720.0) * vec2(width, height) / min(width, height);
    vec2 _uv = floor(uv * ratio / 100.0);
    vec2 _fuv = fract(uv * ratio / 100.0);
    vec4 ofs = vec4(-1.0, 0.0, 1.0, 2.0);
    vec2 n4 = random2(_uv + ofs.yy, seed);
    vec2 n7 = random2(_uv + ofs.zy, seed);
    vec2 n10 = random2(_uv + ofs.yz, seed);
    vec2 n13 = random2(_uv + ofs.zz, seed);
    vec2 factor = vec2(0.0);
    factor = _fuv;
    // factor = smoothstep(0.0, 1.0, _fuv);
    factor = _fuv * _fuv * _fuv * (_fuv * (_fuv * 6.0 - 15.0) + 10.0);
    float ret = mix(
        mix(dot(n4, _fuv - ofs.yy), dot(n7, _fuv - ofs.zy), factor.x),
        mix(dot(n10, _fuv - ofs.yz), dot(n13, _fuv - ofs.zz), factor.x),
        factor.y
    );
    // ret = sign(ret) * pow(abs(ret), 0.85);

    ret = 2./(1.+exp(-3.*ret))-1.0;
    ret = ret * 0.5 + 0.5;
    // ret = 1.6 * ret - 0.6*ret * ret * ret * (ret * (ret * 6.0 - 15.0) + 10.0);
    // ret = ret * ret * ret * (ret * (ret * 6.0 - 15.0) + 10.0);
    // ret = smoothstep(0., 1., ret);
    return ret ;
}


float gradient_noise(vec2 uv, float complexity, float evolution, float subImpact,
                    float subScale, float subRotate, float rand, vec2 subOffset)
{
    vec2 ratio = vec2(720.0) * vec2(width, height) / min(width, height);
    float ic = floor(complexity);
    float fc = fract(complexity);
    float ie = (evolution);
    float fe = fract(evolution);
    float layer = interpolation(uv, vec2(ie, 1.0 + rand));
    float sumWeight = 1.0;
    float weight = subImpact;
    float sum = layer * 1.0;
    for (float i = 2.0; i <= 10.0; i += 1.0)
    {
        if (i > ic) break;
        uv -= subOffset / ratio;
        uv = rotate(uv, subRotate * PI / 180.0);
        uv *= subScale;

        layer = interpolation(uv, vec2(ie, 1.0 + rand)) * weight;

        sumWeight += weight;
        weight *= subImpact;
        sum += layer;
    }
    uv -= subOffset / ratio;
    uv = rotate(uv, subRotate * PI / 180.0);
    uv *= subScale;
    layer = interpolation(uv, vec2(ie, 1.0 + rand)) * weight * fc;
    sumWeight += weight * fc;
    sum += layer;
    sum /= sumWeight;
    return clamp(sum, 0.0, 1.0);
}

void main() {
    vec2 uv = uv0;
    uv -= u_Offset;
    uv = rotate(uv, u_Rotate * PI / 180.0);
    uv = uv * (1. / u_Scale);
    uv -= 10.0;

	float n1 = 0.5;
    float n2 = 0.5;
    if (u_type < 0.5)
    {
        n1 = gradient_noise(uv, clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 2.11, u_SubOffset);
        n2 = gradient_noise(uv, clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 9.71, u_SubOffset);
    }
    else
    {
        n1 = gradient_noise(vec2(0.5, uv.y), clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 2.11, u_SubOffset);
        n2 = gradient_noise(vec2(uv.x, 0.5), clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 9.71, u_SubOffset);
    }

    gl_FragColor = vec2ToVec4(vec2(n1, n2));
}