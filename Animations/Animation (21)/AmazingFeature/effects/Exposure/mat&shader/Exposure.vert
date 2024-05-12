precision highp float;

attribute vec3 position;
attribute vec2 texcoord0;
varying vec2 uv0;
uniform mat4 u_MVP;

varying vec3 local_pos;

void main() 
{ 
    gl_Position = vec4(position, 1.0);
    uv0 = texcoord0;
    local_pos = position;
}
