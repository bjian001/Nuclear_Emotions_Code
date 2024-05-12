precision highp float;

varying vec2 uv0;

uniform sampler2D inputTex1;

uniform float alpha;
uniform float scale;
uniform vec2 pos;
uniform vec2 pivot;

uniform vec4 u_ScreenParams;

vec2 Mirror(vec2 x) { return abs(mod(x-1., 2.)-1.); }

float cut(vec2 u) {return step(0., u.x)*step(u.x, 1.)*step(0., u.y)*step(u.y, 1.); }

void main()
{
    vec2 uv1 = uv0;
    uv1 += pos;
    uv1 -= pivot;
    uv1 /= scale;
    uv1 += pivot;
    vec4 col1 = texture2D(inputTex1, Mirror(uv1));


    vec4 res = col1 * alpha;

    gl_FragColor = res;
}
