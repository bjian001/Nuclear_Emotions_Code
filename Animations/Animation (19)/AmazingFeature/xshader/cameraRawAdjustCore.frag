precision highp float;
uniform sampler2D inputTex;
uniform sampler2D guidedFilterTex;
uniform vec4 u_ScreenParams;

uniform vec2 u_eyepos1;
uniform vec2 u_eyepos2;
uniform vec2 u_NosePos;

uniform vec2 u_lightSmooth;

uniform float u_eyeDistance1;
uniform float u_eyeDistance2;
uniform float u_NoseDistance;
uniform float u_eyeStartsmooth;
uniform float u_noseStartsmooth;
uniform float u_protectFace;
uniform float u_intensity;
uniform float u_useMatting;

varying vec2 uv;
const vec3 grayVec =  vec3(0.2126, 0.7152, 0.0722);



void main()
{
    vec4 nowColor = texture2D(guidedFilterTex,uv);
    float edgeColor = smoothstep(u_lightSmooth.x, u_lightSmooth.y, dot(grayVec,nowColor.rgb))*mix(1.0,texture2D(inputTex,vec2(uv.x,1.-uv.y)).r,u_useMatting);
    float mask = 1.0;
    mask *= smoothstep(u_noseStartsmooth, 1.0, distance(uv, u_NosePos)/u_NoseDistance);
    mask = max(mask, 1. - smoothstep(u_eyeStartsmooth, 1.0, distance(uv, u_eyepos1)/u_eyeDistance1));
    mask = max(mask, 1. - smoothstep(u_eyeStartsmooth, 1.0, distance(uv, u_eyepos2)/u_eyeDistance2));
    mask = mix(1.0,mask,u_protectFace);
    gl_FragColor = vec4(edgeColor*mask*u_intensity);
}