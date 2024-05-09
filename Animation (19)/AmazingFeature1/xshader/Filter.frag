precision highp float;
varying vec2 uv0;
varying vec2 uv1;

uniform sampler2D inputImageTexture;
uniform float uniAlpha;


void main()
{
    vec4 curColor = texture2D(inputImageTexture,uv0);
    gl_FragColor = curColor;
    // gl_FragColor = curColor;
}