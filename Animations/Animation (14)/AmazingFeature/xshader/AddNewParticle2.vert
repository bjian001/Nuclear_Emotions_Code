precision highp float;
attribute vec3 position;
attribute vec2 texcoord0;

uniform sampler2D u_flowTex;
uniform vec2 u_randSeed;
uniform vec2 u_frameSize;
varying vec2 v_particleAttrCoord;
varying vec2 v_flowCoord;
varying float v_randStatic;
varying float v_randRate;
varying vec2 v_randSpeedVal;


float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 get_random_pos(vec2 coord) {
    vec2 res = coord;
    float x = random(coord + u_randSeed.x);
    float y = random(coord + u_randSeed.y);
    res = vec2(x, y);

    return res;
} 

void main() 
{ 
    v_particleAttrCoord = texcoord0;
    v_flowCoord = get_random_pos(texcoord0);
    gl_Position = vec4(position, 1.0);
    gl_PointSize = 1.0;

    v_randStatic = random(v_flowCoord + u_randSeed.x/2.0 + u_randSeed.y);
    v_randRate = random(v_flowCoord + u_randSeed.x + u_randSeed.y);

    v_randSpeedVal = vec2(random(v_flowCoord + u_randSeed.x/3.0), random(v_flowCoord + u_randSeed.y/3.0));
    v_randSpeedVal = v_randSpeedVal * 0.01 - 0.005;
    v_randSpeedVal.y *= u_frameSize.x / u_frameSize.y;
    
}