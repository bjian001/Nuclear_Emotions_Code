precision highp float;

attribute vec2 attPosition;
attribute vec2 attTexcoord0;
varying vec2 uv0;
//uniform mat4 u_MVP;
void main() 
{ 
    //gl_Position = u_MVP * position;
    gl_Position = sign(vec4(attPosition.xy, 0.0, 1.0));
    uv0 = attTexcoord0;
}
