precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;

void main()
{
    vec2 uv = uv0;
    gl_FragColor = texture2D(u_InputTex, uv); 
}
