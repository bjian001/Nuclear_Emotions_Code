precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform vec4 u_ScreenParams;
uniform float threshold;
uniform float randomly;
uniform float triggerType;
uniform float sortType;
uniform float affectType;
uniform float randomSeed;
uniform float blockSize;


#define SIZE 256.0

float hash21(vec2 p){
    vec2 p2 = fract(p*1324.518);
    p2+=dot(p2,p2.yx+22.541);
    return fract((p2.x+p2.y)*p2.y);
}


float avg(vec4 color)
{
    return (color.r + color.g + color.b)/3.0;
}

float red(vec4 color)
{
    return color.r;
}

float green(vec4 color)
{
    return color.g;
}

float blue(vec4 color)
{
    return color.b;
}

float maxC(vec4 color)
{
    return max(max(color.r, color.g), color.b);
}

float minC(vec4 color)
{
    return min(min(color.r, color.g), color.b);
}

float brightness(vec4 color)
{
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}

vec3 rgb2hsv(vec3 rgb) {
    float cmin = min(min(rgb.r, rgb.g), rgb.b);
    float cmax = max(max(rgb.r, rgb.g), rgb.b);
    float cdelta = cmax - cmin;

    float h = 0.0;
    float s = 0.0;
    float v = cmax;

    if (cdelta != 0.0) {
        s = cdelta / cmax;

        float rdelta = (((cmax - rgb.r) / 6.0) + (cdelta / 2.0)) / cdelta;
        float gdelta = (((cmax - rgb.g) / 6.0) + (cdelta / 2.0)) / cdelta;
        float bdelta = (((cmax - rgb.b) / 6.0) + (cdelta / 2.0)) / cdelta;

        if (rgb.r == cmax) {
            h = bdelta - gdelta;
        } else if (rgb.g == cmax) {
            h = (1.0 / 3.0) + rdelta - bdelta;
        } else if (rgb.b == cmax) {
            h = (2.0 / 3.0) + gdelta - rdelta;
        }

        if (h < 0.0) {
            h += 1.0;
        } else if (h > 1.0) {
            h -= 1.0;
        }
    }

    return vec3(h, s, v);
}

float hue(vec4 color)
{
    return rgb2hsv(color.rgb).r ;
}

float saturation(vec4 color)
{
    return rgb2hsv(color.rgb).g;
}


float bitwiseXOR(vec2 p)
{
    float result = 0.0;
    for(float n = 0.0; n < 8.0; n+=1.0)
    {
        vec2 a = floor(p);
        result += mod(a.x+a.y,2.0);
        p/=2.0;
        result/=2.0;
    };
    return result*2.0;
}

float bitwiseXOR3(vec3 p)
{
    float result = 0.0;
    for(float n = 0.0; n < 8.0; n+=1.0)
    {
        vec3 a = floor(p);
        result += mod(a.x+a.y+a.z,2.0);
        p/=2.0;
        // result/=2.0;
    };
    return result/8.0;
}

float xor(vec4 color)
{
    // return bitwiseXOR3(color.rgb*255.0);
    return bitwiseXOR(vec2(bitwiseXOR(color.rg*255.0),color.b)*255.0);
}

float thresholdFun(vec4 color, float tpye)
{
    if (tpye < 0.5)
    {
        return brightness(color);
    } 
    else if (tpye < 1.5)
    {
        return avg(color);
    }
    else if (tpye < 2.5)
    {
        return minC(color);
    }
    else if (tpye < 3.5)
    {
        return maxC(color);
    }
    else if (tpye < 4.5)
    {
        return red(color);
    }
    else if (tpye < 5.5)
    {
        return green(color);
    }
    else if (tpye < 6.5)
    {
        return blue(color);
    }
    else if (tpye < 7.5)
    {
        return hue(color);
    }
    else if (tpye < 8.5)
    {
        return saturation(color);
    }
    else if (tpye < 9.5)
    {
        return xor(color);
    }
    else
    {
        return brightness(color);
    }
    
}


void main() {
    vec2 uv = uv0;

    float noise = hash21(vec2(uv.x+randomSeed*10.0, uv.y))+0.001;
    vec4 color = texture2D(inputImageTexture, uv);
    if (color.a < 0.01)
    {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    float sortVal = thresholdFun(color, sortType);
    float triggerVal = thresholdFun(color, triggerType);
    if (blockSize >= 2.0)
    {
        uv = floor(uv*u_ScreenParams.xy/floor(blockSize))*floor(blockSize)/u_ScreenParams.xy;
        triggerVal = thresholdFun(texture2D(inputImageTexture, uv), sortType);
    }
    if (((affectType <= 0.5 && triggerVal >= threshold) || (affectType > 0.5 && triggerVal <= threshold)) && noise >= randomly/16.0)
    {
        gl_FragColor = vec4(1.0, sortVal, sortVal, 1.0);
    }
    else
    {
        gl_FragColor = vec4(0.0, sortVal, sortVal, 1.0);
    }
}