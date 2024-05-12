precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform vec4 u_ScreenParams;
uniform sampler2D oriImageTexture;
uniform sampler2D alphaImageTexture;
uniform float flag;



void main() {
    vec2 uv = uv0;
    vec4 col = texture2D(inputImageTexture,uv);
    vec4 oriCol = texture2D(oriImageTexture,uv);
    col = mix(col,oriCol,step(0.5,flag));
    gl_FragColor = vec4(col.rgb,texture2D(alphaImageTexture,uv).a);
    
}