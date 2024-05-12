precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform float u_Convergence;
uniform float u_Radius;
uniform vec2 u_Center;
uniform float whiteOpacity;
uniform float screenW;
uniform float screenH;
vec2 uvProtect(vec2 uv)
{
    return step(vec2(0.0), uv) * step(uv, vec2(1.0));
}

vec3 barrel(vec2 uv, float radius, float convergence)
{
    vec2 distortionCenter = u_Center;
    vec2 tuv = (uv - distortionCenter);
    tuv.x *= screenW / screenH;
    float distortion_k1 = -convergence * 203.0875 / pow(radius, 2.0);
    float distortion_k2 = 0.0;
    float rr = length(tuv);
    float r2 = rr * (1.0 + distortion_k1 * (rr * rr) + distortion_k2 * (rr * rr * rr));
    float theta = atan(tuv.x, tuv.y);
    float distortion_x = sin(theta) * r2 * 1.0;
    float distortion_y = cos(theta) * r2 * 1.0;
    vec2 dest_uv = vec2(distortion_x, distortion_y);
    dest_uv.x *= screenH / screenW;
    dest_uv += distortionCenter;
    return vec3(dest_uv, rr);
}

void main()
{
    vec2 uv = uv0;
    float r = u_Radius * pow(1.6, screenW / screenH - 1.0);
    vec3 x = barrel(uv0, r, u_Convergence);
    uv = x.xy;
    vec2 uvp = uvProtect(uv);
    vec4 resultColor = texture2D(u_InputTex, uv) * uvp.x * uvp.y * smoothstep(r * 0.007 + 0.001, r * 0.007 - 0.001, x.z);
    resultColor.rgb = mix(resultColor.rgb, clamp(vec3(1), 0., 1.), whiteOpacity);
    resultColor.a = 1. - (1. - resultColor.a) * (1. - whiteOpacity);
    gl_FragColor = resultColor;
}
