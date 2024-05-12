precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform float u_Threshold;
uniform float lightCut;
vec3 grayFactor = vec3(76.5/255.0, 150.0/255.0, 28.5/255.0);
void main()
{
    vec4 oriColor = texture2D(u_InputTex, uv0);
    float gray = dot(oriColor.rgb, grayFactor);
    gl_FragColor = vec4(mix(step(u_Threshold / 255.0, gray), 1. - step(u_Threshold / 255.0, gray), lightCut));
    // gl_FragColor = vec4(gray);
}
