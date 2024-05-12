precision highp float;

uniform sampler2D inputImageTexture;

varying vec2 uv;

#define textureCoordinate uv
uniform float baseTexWidth;
uniform float baseTexHeight;
uniform float iTime;
void main()
{
   
    vec4 col = texture2D(inputImageTexture,uv)*(iTime+0.5);
    
    gl_FragColor = vec4(col);
}