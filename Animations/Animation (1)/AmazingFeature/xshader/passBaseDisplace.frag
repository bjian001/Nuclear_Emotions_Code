precision highp float;
varying highp vec2 uv0;
uniform sampler2D baseTex;
uniform sampler2D grainTex;
uniform float offsetX;
uniform float offsetY;
uniform float intensity;
uniform vec2 scale;
uniform vec2 offset;
// vec2 flip_uv(vec2 uv)
// {
//     vec2 z = abs(mod(uv + 1., 2.) - 1.0);
//     return mod(z, 1.0);
// }

// vec2 scale_uv(vec2 uv, float scale)
// {
//     uv -= .5;
//     uv *= 1.0 / scale;
//     uv += .5;
//     return uv;
// }

float uvProtect(vec2 uv)
{
    vec2 _uv = step(uv, vec2(1.0)) * step(vec2(0.0), uv);
    return _uv.x * _uv.y;
}

void main()
{
    vec4 grainColor = texture2D(grainTex, uv0);
    float offsetX = offset.x * (.5 - grainColor.r) * 2. * intensity;
    float offsetY = offset.y * (.5 - grainColor.g) * 2. * intensity;
    vec2 uv1 = uv0 - vec2(offsetX, offsetY);
    uv1 = (uv1 - .5) / scale + .5;
    vec4 displaceColor = texture2D(baseTex, uv1) * uvProtect(uv1);

    vec4 resultColor = displaceColor;
    gl_FragColor = resultColor;

}
