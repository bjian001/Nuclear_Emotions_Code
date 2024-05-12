precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTexture;
uniform float xOffset;
uniform float yOffset;
uniform float scaleIns;
uniform vec4 u_ScreenParams;
uniform float noiseIns;
uniform sampler2D noiseTex;
vec2 flip_uv(vec2 uv)
{
    return abs(mod(uv+1.,2.)-1.);
}
mat2 scale(float scaleIns){
    return mat2(1.0/(scaleIns + 0.000001),0.,0.,1.0/(scaleIns + 0.000001));
}
void main()
{
    vec2 translate=vec2(xOffset,yOffset);
    vec2 uv1=uv0;
    uv1=uv1-translate;
    uv1 -= 0.5;
    uv1=uv1/vec2(scaleIns, 1.0);
    uv1 += 0.5;

    vec4 noiseCol = texture2D(noiseTex,uv1);
    uv1 = uv1 + vec2(0.0, noiseCol.r - 0.5) * -noiseIns / u_ScreenParams.y;

    uv1=flip_uv(uv1);
    
    gl_FragColor=texture2D(inputTexture,uv1);
}
