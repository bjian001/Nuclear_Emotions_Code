precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 uv0;

uniform float picture_scale;

void main() {
    gl_Position = vec4(attPosition,1.0);
    uv0 = attUV.xy;
    uv0 -= 0.5;
    uv0 /= picture_scale;
    uv0 += 0.5;
}
