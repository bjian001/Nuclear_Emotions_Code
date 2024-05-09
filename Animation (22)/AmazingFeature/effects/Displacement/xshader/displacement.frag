precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform sampler2D _MainTex;
// uniform sampler2D turTex;
// uniform vec4 u_ScreenParams;
uniform float u_Complexity;
uniform float u_Evolution;
uniform float u_Cycle;
uniform float u_Brightness;
uniform float u_Contrast;
uniform float u_Range;

uniform vec2 u_Scale;
uniform vec2 u_Offset;
uniform float u_Rotate;
uniform float u_SubImpact;
uniform float u_SubScale;
uniform float u_SubRotate;
uniform vec2 u_SubOffset;
uniform float u_type;
uniform float u_fix_type;
uniform float motion_tile_type;
uniform float width;
uniform float height;
uniform float screenIntensity;

// #define PI 3.1415926
// #define HASHSCALE3 vec3(.8031, .1030, .3973)
// float hash21(vec2 p){
//     vec2 p2 = fract(p*1324.518);
//     p2+=dot(p2,p2.yx+22.541);
//     return fract((p2.x+p2.y)*p2.y);
// }

vec2 Mirror(vec2 x) { return abs(mod(x-1., 2.)-1.); }
float cut(vec2 u) {return step(0., u.x)*step(u.x, 1.)*step(0., u.y)*step(u.y, 1.); }

// vec2 flip_uv(vec2 uv)
// {
//     vec2 z = abs(mod(uv + 1., 2.) - 1.0);
//     return mod(z, 1.0);
// }

// vec2 random2(vec2 p, vec2 seed){

//     float n = hash21((p.xy));
//     float n2 = 4.412;
//     float evol = seed.x + n;
//     float evol0 = floor(evol);
//     float evol1 = evol0+1.0;
//     if(u_Cycle >= 2.0)
//     {
//         evol0 = floor(mod(evol, u_Cycle));
//         evol1 = floor(mod(evol+1.0, u_Cycle));
//     }
//     vec2 p2 = fract((p.xy)*(34.532+evol0*n2 + (seed.y) * HASHSCALE3.x));
//     p2+=dot(p2,p2.yx+15.434);
//     vec2 result1 = fract((p2.xy+p2.yx + 0.523)*p2.yx+n);

//     vec2 p22 = fract((p.xy)*(34.532+evol1*n2 + (seed.y) * HASHSCALE3.x));
//     p22+=dot(p22,p22.yx+15.434);
//     vec2 result2 = fract((p22.xy+p22.yx + 0.523)*p22.yx+n);

//     float w = fract(evol);
//     // w = 1.6 * w - 0.6*w * w * w * (w * (w * 6.0 - 15.0) + 10.0);
//     // w = smoothstep(0.0, 1.0, w);
//     // w = sign(w-0.5)*(2.*w-1.)*(2.*w-1.)*0.5+0.5;
//     // w = sign(w-0.5) * pow(abs(w-0.5)*2., 1.2)*0.5+0.5;

//     return mix(result1, result2, w) * 2.0 - 1.0;
//     // return  vec2(n);
// }

// vec2 rotate(vec2 uv, float theta)
// {
//     uv.y *= u_ScreenParams.y / u_ScreenParams.x;
//     float sint = sin(theta);
//     float cost = cos(theta);
//     mat2 rot = mat2(
//         cost, sint,
//         -sint, cost
//     );
//     // uv -= 0.5;
//     uv = rot * uv;
//     // uv += 0.5;
//     uv.y *= u_ScreenParams.x / u_ScreenParams.y;
//     return uv;
// }


// float interpolation(vec2 uv, vec2 seed)
// {
//     vec2 ratio = vec2(720.0) * u_ScreenParams.xy / min(u_ScreenParams.x, u_ScreenParams.y);
//     vec2 _uv = floor(uv * ratio / 100.0);
//     vec2 _fuv = fract(uv * ratio / 100.0);
//     vec4 ofs = vec4(-1.0, 0.0, 1.0, 2.0);
//     vec2 n4 = random2(_uv + ofs.yy, seed);
//     vec2 n7 = random2(_uv + ofs.zy, seed);
//     vec2 n10 = random2(_uv + ofs.yz, seed);
//     vec2 n13 = random2(_uv + ofs.zz, seed);
//     vec2 factor = vec2(0.0);
//     factor = _fuv;
//     // factor = smoothstep(0.0, 1.0, _fuv);
//     factor = _fuv * _fuv * _fuv * (_fuv * (_fuv * 6.0 - 15.0) + 10.0);
//     float ret = mix(
//         mix(dot(n4, _fuv - ofs.yy), dot(n7, _fuv - ofs.zy), factor.x),
//         mix(dot(n10, _fuv - ofs.yz), dot(n13, _fuv - ofs.zz), factor.x),
//         factor.y
//     );
//     // ret = sign(ret) * pow(abs(ret), 0.85);

//     ret = 2./(1.+exp(-3.*ret))-1.0;
//     ret = ret * 0.5 + 0.5;
//     // ret = 1.6 * ret - 0.6*ret * ret * ret * (ret * (ret * 6.0 - 15.0) + 10.0);
//     // ret = ret * ret * ret * (ret * (ret * 6.0 - 15.0) + 10.0);
//     // ret = smoothstep(0., 1., ret);
//     return ret ;
// }


// float gradient_noise(vec2 uv, float complexity, float evolution, float subImpact,
//                     float subScale, float subRotate, float rand, vec2 subOffset)
// {
//     vec2 ratio = vec2(720.0) * u_ScreenParams.xy / min(u_ScreenParams.x, u_ScreenParams.y);
//     float ic = floor(complexity);
//     float fc = fract(complexity);
//     float ie = (evolution);
//     float fe = fract(evolution);
//     float layer = interpolation(uv, vec2(ie, 1.0 + rand));
//     float sumWeight = 1.0;
//     float weight = subImpact;
//     float sum = layer * 1.0;
//     for (float i = 2.0; i <= 10.0; i += 1.0)
//     {
//         if (i > ic) break;
//         uv -= subOffset / ratio;
//         uv = rotate(uv, subRotate * PI / 180.0);
//         uv *= subScale;

//         layer = interpolation(uv, vec2(ie, 1.0 + rand)) * weight;

//         sumWeight += weight;
//         weight *= subImpact;
//         sum += layer;
//     }
//     uv -= subOffset / ratio;
//     uv = rotate(uv, subRotate * PI / 180.0);
//     uv *= subScale;
//     layer = interpolation(uv, vec2(ie, 1.0 + rand)) * weight * fc;
//     sumWeight += weight * fc;
//     sum += layer;
//     sum /= sumWeight;
//     return clamp(sum, 0.0, 1.0);
// }

float colorAdjust(float c, float brightness, float contrast)
{
    c += brightness;
    c = (c - 0.5) * contrast * 10.0 + 0.5;
    return c;
}

// float uvProtect(vec2 uv)
// {
//     vec2 _uv = step(uv, vec2(1.0)) * step(vec2(0.0), uv);
//     return _uv.x * _uv.y;
// }

void main() {
    // vec2 uv = uv0;
    // uv -= u_Offset;
    // uv = rotate(uv, u_Rotate * PI / 180.0);
    // uv = uv * (1. / u_Scale);
    // uv -= 10.0;

	float n1 = 0.5;
    float n2 = 0.5;
    // if (u_type < 0.5)
    // {
    //     n1 = gradient_noise(uv, clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 2.11, u_SubOffset);
    //     n2 = gradient_noise(uv, clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 9.71, u_SubOffset);
    // }
    // else
    // {
    //     n1 = gradient_noise(vec2(0.5, uv.y), clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 2.11, u_SubOffset);
    //     n2 = gradient_noise(vec2(uv.x, 0.5), clamp(u_Complexity, 1.0, 10.0), u_Evolution, u_SubImpact, 100.0 / u_SubScale, u_SubRotate, 9.71, u_SubOffset);
    // }

    vec2 baseTextureSize= vec2(width, height);//u_ScreenParams.xy;
    vec2 sucaiSize=vec2(1080,1080);
    vec2 fullBlendAnchor=baseTextureSize*.5;
    float scale=1.;
    float baseAspectRatio=baseTextureSize.y/baseTextureSize.x;
    float blendAspectRatio=sucaiSize.y/sucaiSize.x;
    if(baseAspectRatio>=blendAspectRatio){
        scale=baseTextureSize.y/sucaiSize.y;
    }else{
        scale=baseTextureSize.x/sucaiSize.x;
    }
    vec2 baseTextureCoord=uv0*baseTextureSize;
    float sizeIntensity = 0.;
    vec2 tempSucaiUV=(baseTextureCoord-fullBlendAnchor)/(sucaiSize*scale * (sizeIntensity + 1.))+vec2(.5);
    tempSucaiUV.y = 1.0-tempSucaiUV.y;

    vec4 nColor = texture2D(_MainTex, tempSucaiUV);
    n1 = nColor.x;
    n2 = nColor.y;
    n1 = colorAdjust(n1, u_Brightness, u_Contrast);
    n2 = colorAdjust(n2, u_Brightness, u_Contrast);

    // n2 = (n2-0.5)*u_ScreenParams.x/u_ScreenParams.y+0.5;

    float ins = clamp(u_Scale.x, 0.01, 1.0) * u_Range;
    vec2 new_uv = uv0;
    vec4 res = vec4(0.0);
    if (u_type < 0.5)
    {
        new_uv = vec2(uv0.x+(n1-0.5)*ins, uv0.y+(n2-0.5)*ins);
    }
    else if (u_type < 1.5)
    {
        new_uv = vec2(uv0.x+(n1-0.5)*ins, uv0.y);
    }
    else if(u_type < 2.5)
    {
        new_uv = vec2(uv0.x, uv0.y+(n2-0.5)*ins);
    }
    else
    {
        new_uv = vec2(uv0.x+(n1-0.5)*ins, uv0.y+(n2-0.5)*ins);
    }

    if (u_fix_type < 0.5)
    {
        // if (clamp(new_uv, 0.0, 1.0) == new_uv)
        // {
            // res = texture2D(inputImageTexture, new_uv);
        // }
    }
    else if (u_fix_type < 1.5)
    {
        if (uv0.x < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        if (uv0.x > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        if (uv0.y < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        if (uv0.y > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 2.5)
    {
        if (clamp(new_uv.x, 0.0, 1.0) == new_uv.x)
        {
            if (uv0.y < 0.25)
            {
                float w = smoothstep(0.0, 0.25, uv0.y);
                new_uv.y = mix(uv0.y, new_uv.y, w);
            }
            if (uv0.y > 0.75)
            {
                float w = smoothstep(0.0, 0.25, 1.0 - uv0.y);
                new_uv.y = mix(uv0.y, new_uv.y, w);
            }
            // res = texture2D(inputImageTexture, new_uv);
        }
    }
    else if (u_fix_type < 3.5)
    {
        if (clamp(new_uv.y, 0.0, 1.0) == new_uv.y)
        {
            if (uv0.x < 0.25)
            {
                float w = smoothstep(0.0, 0.25, uv0.x);
                new_uv.x = mix(uv0.x, new_uv.x, w);
            }
            if (uv0.x > 0.75)
            {
                float w = smoothstep(0.0, 0.25, 1.0 - uv0.x);
                new_uv.x = mix(uv0.x, new_uv.x, w);
            }
            // res = texture2D(inputImageTexture, new_uv);
        }
    }
    else if (u_fix_type < 4.5)
    {
        if (new_uv.x <= 1.0 && clamp(new_uv.y, 0.0, 1.0) == new_uv.y)
        {
            if (uv0.x < 0.25)
            {
                float w = smoothstep(0.0, 0.25, uv0.x);
                new_uv.x = mix(uv0.x, new_uv.x, w);
            }
            // res = texture2D(inputImageTexture, new_uv);
        }
    }
    else if (u_fix_type < 5.5)
    {
        if (new_uv.x >= 0.0 && clamp(new_uv.y, 0.0, 1.0) == new_uv.y)
        {
            if (uv0.x > 0.75)
            {
                float w = smoothstep(0.0, 0.25, 1.0 - uv0.x);
                new_uv.x = mix(uv0.x, new_uv.x, w);
            }
            // res = texture2D(inputImageTexture, new_uv);
        }
    }
    else if (u_fix_type < 6.5)
    {
        if (new_uv.y >= 0.0 && clamp(new_uv.x, 0.0, 1.0) == new_uv.x)
        {
            if (uv0.y > 0.75)
            {
                float w = smoothstep(0.0, 0.25, 1.0 - uv0.y);
                new_uv.y = mix(uv0.y, new_uv.y, w);
            }
            // res = texture2D(inputImageTexture, new_uv);
        }
    }
    else if (u_fix_type < 7.5)
    {
        if (new_uv.y <= 1.0 && clamp(new_uv.x, 0.0, 1.0) == new_uv.x)
        {
            if (uv0.y < 0.25)
            {
                float w = smoothstep(0.0, 0.25, uv0.y);
                new_uv.y = mix(uv0.y, new_uv.y, w);
            }
            // res = texture2D(inputImageTexture, new_uv);
        }
    }
    else if (u_fix_type < 8.5)
    {
        if (uv0.x < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        if (uv0.x > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        if (uv0.y < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        if (uv0.y > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        float w = 1.0;
        if (uv0.x < 0.1)
        {
            w = min(w, uv0.x*10.0);
        }
        if (uv0.x > 0.9)
        {
            w = min(w, (1.0-uv0.x)*10.0);
        }
        if (uv0.y < 0.1)
        {
            w = min(w, uv0.y*10.0);
        }
        if (uv0.y > 0.9)
        {
            w = min(w, (1.0-uv0.y)*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 9.5)
    {
        if (uv0.y < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        if (uv0.y > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        float w = 1.0;
        if (uv0.y < 0.1)
        {
            w = min(w, uv0.y*10.0);
        }
        if (uv0.y > 0.9)
        {
            w = min(w, (1.0-uv0.y)*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 10.5)
    {
        if (uv0.x < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        if (uv0.x > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        float w = 1.0;
        if (uv0.x < 0.1)
        {
            w = min(w, uv0.x*10.0);
        }
        if (uv0.x > 0.9)
        {
            w = min(w, (1.0-uv0.x)*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 11.5)
    {
        if (uv0.x < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        float w = 1.0;
        if (uv0.x < 0.1)
        {
            w = min(w, uv0.x*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 12.5)
    {
        if (uv0.x > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.x);
            new_uv.x = mix(uv0.x, new_uv.x, w);
        }
        float w = 1.0;
        if (uv0.x > 0.9)
        {
            w = min(w, (1.0-uv0.x)*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 13.5)
    {
        if (uv0.y > 0.75)
        {
            float w = smoothstep(0.0, 0.25, 1.0 - uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        float w = 1.0;
        if (uv0.y > 0.9)
        {
            w = min(w, (1.0-uv0.y)*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    else if (u_fix_type < 14.5)
    {
        if (uv0.y < 0.25)
        {
            float w = smoothstep(0.0, 0.25, uv0.y);
            new_uv.y = mix(uv0.y, new_uv.y, w);
        }
        float w = 1.0;
        if (uv0.y < 0.1)
        {
            w = min(w, uv0.y*10.0);
        }
        new_uv = mix(uv0, new_uv, w);
        // res = texture2D(inputImageTexture, new_uv);
    }
    // else
    // {
        // res = texture2D(inputImageTexture, new_uv);
    // }
    float mask = 1.;
    if(motion_tile_type < 0.5){
        mask = cut(new_uv);
    }else if(motion_tile_type < 1.5){
        new_uv = fract(new_uv);
    }else{
        new_uv = Mirror(new_uv);
    }
    // res = texture2D(inputImageTexture, new_uv);
    // res *= mask;

    // gl_FragColor = res;
    // // n1 = fract(u_Evolution);
    // // n1 = sign(n1-0.5) * pow(abs(n1-0.5)*2., 0.9)+0.5;
    // // gl_FragColor = vec4(n1, n1, n1, 1.0);
    // vec4 uvColor = texture2D(_MainTex, vec2(uv0.x, 1. - uv0.y));
    // // uvColor.xy = rotate(uvColor.xy - uv0, u_Evolution * PI / 180.) + uv0;
    vec2 uv1 = mix(uv0, (new_uv), 1.);
    vec4 resultColor = texture2D(inputImageTexture, uv1);
    vec4 screenColor = 1. - (1. - resultColor) * (1. - resultColor);
    // screenColor = 1. - (1. - screenColor) * (1. - screenColor);
    resultColor = mix(resultColor, screenColor, 0.);
    gl_FragColor = resultColor;
}