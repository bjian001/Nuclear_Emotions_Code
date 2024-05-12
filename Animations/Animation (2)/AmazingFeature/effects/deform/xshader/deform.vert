precision highp float;

attribute vec2 position;
attribute vec2 texcoord0;
varying vec2 uv0;
uniform float u_Twist;

vec2 white_point(vec2 pos, float twist) {

    if (abs(twist) <= 0.000001) return pos;
    vec2 res_pos = pos;
    vec2 t = res_pos * 0.5 + 0.5;
    
    float r = sin(t.x * 3.1415926) * sin(t.y * 3.1415926);
    float s = mix(1.0, 0.25, abs(twist) * r);
    if (twist > 0.0)
        s = mix(1.0, 1.9, abs(twist) * r);
    res_pos = res_pos * s;
    // r = smoothstep(0.0, 1.0, r);
    return res_pos;
}
vec2 waveform(vec2 pos, float twist) {

    if (abs(twist) <= 0.000001) return pos;
    vec2 res_pos = pos;
    vec2 t = res_pos * 0.5 + 0.5;
    float sint = sin(t.x * 3.1415926 * 2.0);
    res_pos.y -= sint * twist * 0.65 * sin(t.y * 3.1415926);
    return res_pos;
}

void main() 
{ 
    vec4 pos = (vec4(position.xy, 0.0, 1.0));
    pos.xy = white_point(pos.xy, u_Twist);
    gl_Position = pos;
    uv0 = texcoord0;
}
