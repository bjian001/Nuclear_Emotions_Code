precision highp float;
attribute vec3 position;
attribute vec2 texcoord0;
varying vec2 uv;

void main() 
{ 
    gl_Position = vec4(position.xyz, 1.0);
    uv = texcoord0;

    gl_PointSize = 1.0;
}