precision highp float;

varying vec2 uv;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture1;



void main()
{
    gl_FragColor = texture2D(inputImageTexture, uv) + texture2D(inputImageTexture1, uv);
    gl_FragColor.a = texture2D(inputImageTexture1, uv).a;
}
