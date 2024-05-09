precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

uniform vec2 u_pos;
uniform float u_scale;
uniform float u_angle;
uniform vec4 u_size;

varying vec2 uv1;   //bgUV
varying vec2 uv0;   //modelUV

void main ()
{
    // float cosTheta = cos(u_angle);
    // float sinTheta = sin(u_angle);
    // float aspect = u_size.x / u_size.y;
    vec2 pos = attPosition.xy;
    // pos = vec2(pos.x * u_scale, pos.y * u_scale);
    // pos = vec2(pos.x * aspect, pos.y);
    // pos = vec2(cosTheta * pos.x + sinTheta * pos.y, cosTheta * pos.y - sinTheta * pos.x);
    // pos = vec2(pos.x / aspect, pos.y);
    // pos = vec2(pos.x + u_pos.x, pos.y + u_pos.y);
    gl_Position = vec4(pos.xy, attPosition.z, 1.0);
    vec2 uv = vec2(pos.x * 0.5 + 0.5, pos.y * 0.5 + 0.5);
    uv1 = uv;
    uv0 = attUV;
}
