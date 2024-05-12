precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform float u_threshold;
uniform float u_thresholdSmooth;
uniform float u_exposure;
float softLightf(float s, float d)
{
    return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d) 
        : (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0) 
                     : d + (2.0 * s - 1.0) * (sqrt(d) - d);
}
vec3 BlendSoftLight(vec3 s, vec3 d)
{
    return vec3(softLightf(s.r, d.r), softLightf(s.g, d.g), softLightf(s.b, d.b));
}
void main()
{
    vec4 inputColor = texture2D(u_InputTex, uv0);
    vec4 thrColor = vec4(step(vec3(u_threshold), inputColor.rgb), 1.0);
    thrColor.a = clamp(thrColor.r + thrColor.g + thrColor.b, 0.0, 1.0);
    // thrColor.rgb *= inputColor.rgb;
    vec4 blendColor = vec4(BlendSoftLight(thrColor.rgb * inputColor.rgb, inputColor.rgb * u_thresholdSmooth), softLightf(thrColor.a * inputColor.a, inputColor.a * u_thresholdSmooth));
    thrColor = thrColor * inputColor + blendColor * (1.0 - thrColor);
    gl_FragColor = thrColor * u_exposure;
}
