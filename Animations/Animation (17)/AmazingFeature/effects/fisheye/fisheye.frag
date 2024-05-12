precision highp float;

varying vec2 uv0;

uniform sampler2D inputTex;
uniform sampler2D blurTex;
uniform vec2 u_ScreenParams;
uniform float input_fov;
uniform float test_scale;

uniform float d_power;
uniform float z_power;

uniform vec2 circle_info;

vec2 Distort(vec2 _u){
    vec2 p = _u;
    p -= 0.5;
    p.x *= u_ScreenParams.x/u_ScreenParams.y ;
    p *= 0.5;
    float d = length(p);
    // float r = d/(1.+pow(d, d_power)*input_fov);
    float r = d/(1.+pow(d, 3.)*input_fov);
    float phi = atan(p.y, p.x);
    p = vec2(r*cos(phi), r*sin(phi));
    p /= 0.5;
    p.x /= u_ScreenParams.x/u_ScreenParams.y;
    p += 0.5;
    return p;
}

float DiagnalLen(){
    vec2 screenSize = vec2(u_ScreenParams.x, u_ScreenParams.y);
    float maxlen = max(screenSize.x/screenSize.y, screenSize.y/screenSize.x);
    return length(vec2(maxlen, 1.));
}

vec2 Barrel(vec2 _u){
    vec2 uv = _u-0.5;
    float d = length(uv);
    d *= 2.;
    // d = 3.*d*d-2.*d*d*d;
    d = mix(
        pow(d, 1.0 / input_fov),
        d,
        smoothstep(DiagnalLen() * 0.5, DiagnalLen() * 1., d));
    uv = normalize(uv) * d * 0.5;
    uv += 0.5;
    return uv;
}

float circle_mask(vec2 _u){
    vec2 uv = _u - 0.5;
    float d = length(uv) * 2.;
    d = smoothstep(circle_info.x, circle_info.x + circle_info.y + 0.0001, d);
    return d;  
}


void main()
{
    vec2 uv1 = uv0;
    vec4 blurCol = texture2D(blurTex, fract(Barrel(uv1)));
    vec4 inputCol = texture2D(inputTex, fract(Barrel(uv1)));
    vec4 res = mix(blurCol, inputCol, circle_mask(uv0));
    gl_FragColor = res;
}
