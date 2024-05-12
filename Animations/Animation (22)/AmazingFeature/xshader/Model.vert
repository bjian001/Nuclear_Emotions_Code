precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

uniform float u_OutputWidth;
uniform float u_OutputHeight;

uniform mat4 animMat;
uniform mat4 userMat;
uniform mat4 fitMat;

varying vec2 TexCoords;

void transformUV(mat4 mat, out vec2 uv) {
    float aspect = u_OutputWidth / u_OutputHeight;
    uv = vec2((attUV.x * 2. - 1.) * aspect, attUV.y * 2. - 1.);
    uv = (fitMat * userMat * vec4(uv, 0, 1)).xy;
    uv = vec2((uv.x / aspect + 1.) / 2., (uv.y + 1.) / 2.);
}

void main ()
{   
    vec2 uv0 = attUV;
    transformUV(animMat, uv0);
    TexCoords = uv0;
    gl_Position = vec4(attPosition, 1.0);
}
