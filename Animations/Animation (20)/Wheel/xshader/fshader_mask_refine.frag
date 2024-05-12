precision highp float;
varying highp vec2 uv0;

uniform sampler2D maskTexture;
uniform vec4 u_ScreenParams;

uniform float offset;
uniform float offsetRandom;
uniform float randomSeed;
uniform float maxLength;


#define SIZE 256.0

float hash21(vec2 p){
    vec2 p2 = fract(p*1324.518);
    p2+=dot(p2,p2.yx+22.541);
    return fract((p2.x+p2.y)*p2.y);
}

void main() {
    vec4 mask0 = texture2D(maskTexture, uv0);
    vec2 d = 1.0 / vec2(SIZE);
    d.y = 0.0;

    float left = 0.0;
    float right = 0.0;
    if (mask0.x < 0.5)
    {
        gl_FragColor = mask0;
        return;
    }

    if (offset < 0.001 && offsetRandom < 0.001 && maxLength >= 0.999)
    {
        gl_FragColor = mask0;
        return;
    }

    for (float x = 1.0; x < SIZE; x += 1.0)
    {
        vec2 new_uv = uv0 - x * d;
        if (new_uv != clamp(new_uv, 0.0, 1.0))
        {
            break;
        }
        vec4 mask = texture2D(maskTexture, new_uv);
        if(mask.x < 0.5)
        {
            break;
        }
        left = x;
    }
    for (float x = 1.0; x < SIZE; x += 1.0)
    {
        vec2 new_uv = uv0 + x * d;
        if (new_uv != clamp(new_uv, 0.0, 1.0))
        {
            break;
        }
        vec4 mask = texture2D(maskTexture, new_uv);
        if(mask.x < 0.5)
        {
            break;
        }
        right = x;
    }
    float l = left + right + 1.0;
    float noise_off = offset + (hash21(vec2(l + randomSeed, l))-0.5) * offsetRandom;
    float newLeft = l * noise_off;
    if (left < newLeft || left > newLeft+l*maxLength)
    {
        mask0.x = 0.0;
    }

    gl_FragColor = mask0;
}