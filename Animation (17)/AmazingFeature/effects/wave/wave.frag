precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTex;
uniform float u_WaveWidth;
uniform float utime;
uniform float strength;

uniform vec4 u_ScreenParams;

vec2 Mirror(vec2 x) { return abs(mod(x-1., 2.)-1.); }

const float PI = 3.1415926;

void main()
{
    vec2 uv = uv0;
    uv.x += sin(PI*1./u_WaveWidth*uv.y+utime) * 0.0085 * strength;

    vec4 res = texture2D(inputTex, Mirror(uv));

    gl_FragColor = res;
}
