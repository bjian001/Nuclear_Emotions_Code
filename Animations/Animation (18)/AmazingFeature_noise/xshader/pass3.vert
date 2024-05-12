precision highp float;

uniform float u_dst_aspect;
uniform float u_src_aspect;

attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 uv0;
varying vec2 uv1;


vec2 cover (float src_aspect, float dst_aspect, vec2 uv) {
    vec2 sd = vec2(src_aspect, dst_aspect);
    vec2 ds = sd.yx;
    vec2 s = ds / sd;
    vec2 p = (uv - 0.5) * s + 0.5;
    vec2 a = step(ds, sd);
    return mix(uv, p, a);
}

void main() {
    gl_Position = vec4(attPosition,1.0);
    uv0 = attUV;
    uv1 = cover(u_src_aspect, u_dst_aspect, attUV);
    uv1.y = 1.0 - uv1.y;
}
