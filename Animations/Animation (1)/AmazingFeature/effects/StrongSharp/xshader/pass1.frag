precision highp float;
uniform sampler2D inputImageTexture1;
uniform sampler2D inputImageTexture2;
uniform float strength;
uniform float inputScale;
varying vec2 texCoordinate;

void main() {
    vec4 raw_color = texture2D(inputImageTexture1, texCoordinate);
    vec4 blur_color = texture2D(inputImageTexture2, texCoordinate);
    float strengthScale = strength;
    strengthScale = strengthScale*inputScale;
    vec4 resultColor = vec4(raw_color.rgb + (raw_color.rgb - blur_color.rgb) * strengthScale , raw_color.a);
    gl_FragColor = resultColor;
}