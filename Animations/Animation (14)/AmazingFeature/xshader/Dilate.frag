precision highp float;
varying vec2 uv;
uniform sampler2D inputTexture1;
uniform vec2 direction;

void main()
{
    vec2 dir = direction;
    float max_v = texture2D(inputTexture1, uv).r;
    float v1 = texture2D(inputTexture1, uv + dir).r;
    float v2 = texture2D(inputTexture1, uv - dir).r;
    if (v1 > max_v) max_v = v1;
    if (v2 > max_v) max_v = v2;

    gl_FragColor = vec4(vec3(max_v), 1.0);
}