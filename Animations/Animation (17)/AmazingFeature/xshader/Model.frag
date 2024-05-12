precision highp float;
varying vec2 TexCoords;
#define uv0 TexCoords
uniform sampler2D u_inputTexture;

// ---- CODE ----------------------------------------------------------------
uniform float inputHeight;
uniform float inputWidth;
uniform vec2 center;

uniform float blurStep;
uniform mat4 u_InvModel;
uniform vec2 blurDirection;
uniform float mirrorRange;

const float PI = 3.141592653589793;

float cut(vec2 _u){
    return step(0., uv0.x) * step(uv0.x, 1.) * step(0., uv0.y) * step(uv0.y, 1.);
}

void main()
{
    float ratio = inputWidth / inputHeight;

    const int rotateNum = 8;
    float rotateAngle = blurStep * PI / 400.0;

    float fRotateNum = float(rotateNum);
    mat2 startRotateMat = mat2(cos(-rotateAngle * fRotateNum), sin(-rotateAngle * fRotateNum), -sin(-rotateAngle * fRotateNum), cos(-rotateAngle * fRotateNum));    
    mat2 stepRotateMat = mat2(cos(rotateAngle), sin(rotateAngle), -sin(rotateAngle), cos(rotateAngle));

    vec2 uv_ori = uv0 * vec2(ratio, 1.0);
    uv_ori = (u_InvModel * vec4(uv_ori.x * 2.0 - ratio, uv_ori.y * 2.0 - 1.0, 0.0, 1.0)).xy;
    uv_ori.x = (uv_ori.x / ratio + 1.0) / 2.0;
    uv_ori.y = (uv_ori.y + 1.0) / 2.0;

    uv_ori = vec2(1.0 - abs(abs(uv_ori.x) - 1.0), 1.0 - abs(abs(uv_ori.y) - 1.0));
    vec4 res = texture2D(u_inputTexture, uv_ori) * cut(uv_ori);

    gl_FragColor = res;
}
