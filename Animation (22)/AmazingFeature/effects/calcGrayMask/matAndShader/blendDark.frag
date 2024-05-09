precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform sampler2D u_MaskTex;

float uvProtect(vec2 uv)
{
    vec2 _uv = step(uv, vec2(1.0)) * step(vec2(0.0), uv);
    return _uv.x * _uv.y;
}

void main()
{
    vec2 uv1 = (uv0 - .5) * 1.2 + .5;
    vec4 oriColor = texture2D(u_InputTex, uv1) * uvProtect(uv1);
    vec4 maskColor = texture2D(u_MaskTex, uv1) * uvProtect(uv1);
    gl_FragColor = oriColor * maskColor.r;
    // gl_FragColor = vec4(gray);
}
