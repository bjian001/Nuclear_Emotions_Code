precision highp float;
varying highp vec2 uv0;
uniform sampler2D baseTex;
uniform sampler2D blendTex;
uniform float baseOpacity;
uniform float blendOpacity;
uniform float yellowOpacity;
uniform vec3 yellow;

void main()
{
    vec4 baseColor = texture2D(baseTex, uv0) * baseOpacity;
    vec4 blendColor = texture2D(blendTex, uv0) * blendOpacity;
    // blendColor.rgb = mix(clamp(blendColor.rgb / blendColor.a, 0., 1.), yellow / 255., yellowOpacity);
    vec4 resultColor = baseColor;
    resultColor.a = 1. - (1. - baseColor.a) * (1. - blendColor.a);
    resultColor.rgb = mix(baseColor.rgb, clamp(blendColor.rgb / blendColor.a, 0., 1.), blendColor.a);

    gl_FragColor = resultColor;
}
