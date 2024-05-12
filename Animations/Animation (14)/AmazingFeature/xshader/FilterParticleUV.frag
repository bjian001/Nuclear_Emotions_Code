precision highp float;
varying vec2 uv;
uniform sampler2D inputTexture1;
uniform vec2 u_frameSize;

void main()
{
    vec4 offsetUV = texture2D(inputTexture1, uv);
    float offsetSum = abs(offsetUV.x) + abs(offsetUV.y);


    if (length(offsetUV.xy*u_frameSize) > 550.0) {
        offsetUV *= 0.0;
    }


    gl_FragColor = vec4(offsetUV);
}