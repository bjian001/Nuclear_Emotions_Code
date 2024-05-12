precision highp float;

uniform sampler2D u_bgTex;

varying vec2 uv;

void main ()
{
    gl_FragColor = texture2D(u_bgTex, uv);
}

