precision highp float;
varying highp vec2 uv0;
uniform sampler2D mainTex;
uniform sampler2D oriTex;

uniform float bend_intensity;

uniform vec4 u_ScreenParams;

uniform float alpha;

float cut(vec2 _u){
    return step(0., _u.x) * step(_u.x, 1.) * step(0., _u.y) * step(_u.y, 1.);
}

const float PI = 3.1415926;
void BulgeEffect(vec2 i_uv, float bend, out vec2 o_uv){
    
    vec2 uv1 = i_uv;
    uv1 -= 0.5;
    uv1 *= 2.;
    uv1.x *= u_ScreenParams.x/u_ScreenParams.y;

    float bi = bend;

    if(uv1.x < 0.){
        uv1.x -= sin(uv0.y*PI) * bi * abs(uv1.x);
    }else{
        uv1.x += sin(uv0.y*PI) * bi * abs(uv1.x);
    }

    if(uv1.y < 0.){
        uv1.y += pow(sin(uv0.x*PI), 0.5) * bi * abs(uv1.y);
    }else{
        uv1.y -= pow(sin(uv0.x*PI), 0.5) * bi * abs(uv1.y);
    }

    uv1 /= 2.;
    uv1.x /= u_ScreenParams.x/u_ScreenParams.y;
    uv1 += 0.5;

    o_uv = uv1;
}

vec2 Mirror(vec2 x) { return abs(mod(x-1., 2.)-1.); }

void main()
{
    vec2 o_uv=vec2(0); BulgeEffect(uv0, bend_intensity, o_uv);
    vec4 res = texture2D(mainTex, Mirror(o_uv));
    // res *= cut(o_uv); 
    res = mix(res, texture2D(oriTex, Mirror(o_uv)), alpha);
    gl_FragColor = res;
}
