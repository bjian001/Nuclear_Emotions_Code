precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform sampler2D infoTexture;
uniform sampler2D maskTexture;
uniform vec4 u_ScreenParams;
uniform float reverseSort;
uniform float cycle;

#define SIZE 256.0

void main() {
    vec2 d = 1.0 / vec2(SIZE);
    d.y = 0.0;
    vec4 info0 = texture2D(infoTexture, uv0);
    float left = info0.x * (SIZE-1.0);
    float right = info0.y * (SIZE-1.0);
    float sortNum = (info0.z + info0.w)*(SIZE-1.0);

    float sortIdx = left;
    if (reverseSort > 0.5)
    {
        sortIdx = right;
    }
    sortIdx = mod(sortIdx+floor(left+right+1.0)*mod(cycle,1.0), floor(left+right+1.0));

    vec4 res = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 mask0 = texture2D(maskTexture, uv0);
    if (mask0.x < 0.5 || abs(sortNum - sortIdx) < 1.0)
    {
        res.rgb = texture2D(inputImageTexture, uv0).rgb;
        gl_FragColor = res;
        return;
    }

    float min_x = 0.0;
    float min_diff = 1024.0;
    float flag = 0.0;
    for (float x = 1.0; x < SIZE; x += 1.0)
    {
        vec2 new_uv = uv0 - x * d;
        if (new_uv != clamp(new_uv, 0.0, 1.0) || x > left)
        {
            break;
        }
        vec4 info = texture2D(infoTexture, new_uv);
        float num = (info.z + info.w)*(SIZE-1.0);
        float diff = abs(num-sortIdx);
        if (diff < 1.0)
        {
            min_x = -x;
            flag = 1.0;
            break;
        }
        else if(diff < min_diff)
        {
            min_diff = diff;
            min_x = -x;
        }
    }
    if (flag < 0.5)
    {
        for (float x = 1.0; x < SIZE; x += 1.0)
        {
            vec2 new_uv = uv0 + x * d;
            if (new_uv != clamp(new_uv, 0.0, 1.0) || x > right)
            {
                break;
            }
            vec4 info = texture2D(infoTexture, new_uv);
            float num = (info.z + info.w)*(SIZE-1.0);
            float diff = abs(num-sortIdx);
            if (diff < 1.0)
            {
                min_x = x;
                flag = 1.0;
                break;
            }
            else if(diff < min_diff)
            {
                min_diff = diff;
                min_x = x;
            }
        }
    }

    vec2 new_uv = uv0 + min_x * d;
    res.rgb = texture2D(inputImageTexture, new_uv).rgb;
    gl_FragColor = res;
}