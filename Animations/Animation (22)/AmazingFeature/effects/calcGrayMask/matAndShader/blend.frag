precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform sampler2D u_MaskTex;
void main()
{
    vec4 oriColor = texture2D(u_InputTex, uv0);
    vec4 maskColor = texture2D(u_MaskTex, uv0);
    gl_FragColor = oriColor * maskColor.r;
    // gl_FragColor = vec4(gray);
}
