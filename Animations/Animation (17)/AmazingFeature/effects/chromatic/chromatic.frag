precision highp float;

varying vec2 uv0;

uniform sampler2D inputTex;
uniform vec2 u_ScreenParams;
uniform vec2 r_offset;
uniform vec2 g_offset;
uniform vec2 b_offset;

vec2 mirror(vec2 x){
    return abs(mod(x-1.,2.)-1.);
}

void main()
{
    vec2 uv1 = uv0;
    vec4 r_col = texture2D(inputTex, mirror(uv1 + r_offset));
    vec4 g_col = texture2D(inputTex, mirror(uv1 + g_offset));
    vec4 b_col = texture2D(inputTex, mirror(uv1 + b_offset));

    vec4 res = vec4(r_col.r, g_col.g, b_col.b, r_col.a);
    gl_FragColor = res;
}
