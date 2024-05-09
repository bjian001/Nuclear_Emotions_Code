precision highp float;
varying highp vec2 uv0;

uniform sampler2D maskTexture;
uniform vec4 u_ScreenParams;

#define SIZE 256.0

void main() {
    vec4 mask0 = texture2D(maskTexture, uv0);
    vec2 d = 1.0 / vec2(SIZE);
    d.y = 0.0;

    vec4 res =  vec4(0.0, 0.0, 0.0, 0.0); // left, right, min, max
    float sortNum = 0.0;

    if (mask0.x < 0.5)
    {
        gl_FragColor = res;
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
        res.x = x;
        if (mask.y <= mask0.y)
        {
            sortNum += 1.0;
        }
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
        res.y = x;
        if (mask.y < mask0.y)
        {
            sortNum += 1.0;
        }
    }
    res.z = clamp(sortNum, 0.0, (SIZE-1.0));
    res.w = clamp(sortNum - (SIZE-1.0), 0.0, (SIZE-1.0));

    gl_FragColor = res/(SIZE-1.0);
}