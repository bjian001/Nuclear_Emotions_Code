precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform vec4 u_ScreenParams;
uniform float rotate;


#define PI 3.1415926

vec2 rotateFun(vec2 uv, float theta)
{
    float sint = sin(theta);
    float cost = cos(theta);
    mat2 rot = mat2(
        cost, sint,
        -sint, cost
    );
    uv -= 0.5;
    // uv.y *= u_ScreenParams.y / u_ScreenParams.x;
    uv = rot * uv;
    // uv.y /= u_ScreenParams.y / u_ScreenParams.x;
    uv += 0.5;
    return uv;
}


void main() {
    float theta = rotate * PI / 180.0;
    vec2 new_uv = rotateFun(uv0, theta);

    float scale = abs(cos(theta)) + abs(sin(theta));
    new_uv -= 0.5;
    new_uv *= scale;
    new_uv += 0.5;

    gl_FragColor = texture2D(inputImageTexture, new_uv);
    if (new_uv != clamp(new_uv, 0.0, 1.0))
    {
        gl_FragColor.a = 0.0;
    }
}