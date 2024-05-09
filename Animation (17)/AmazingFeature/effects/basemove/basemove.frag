precision highp float;

varying vec2 uv0;

uniform sampler2D inputTex;

uniform float scale;
uniform vec2 pos;

uniform vec4 u_ScreenParams;

vec2 Mirror(vec2 x) { return abs(mod(x-1., 2.)-1.); }

float cut(vec2 u) {return step(0., u.x)*step(u.x, 1.)*step(0., u.y)*step(u.y, 1.); }

void main()
{
    vec2 uv1 = uv0;
    uv1 += pos;
    uv1 -= 0.5;
    // uv1 /= scale;
    uv1 += 0.5;
    // uv1.y = 1.-uv1.y;
    vec4 res = texture2D(inputTex, Mirror(uv1));
    // res = texture2D(inputTex, uv0);
    // res = vec4(1,0,0,0);

    gl_FragColor = res;
}
