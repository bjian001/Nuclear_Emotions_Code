precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTex;
uniform sampler2D inputImageTex;
uniform sampler2D _MainTex;
uniform sampler2D filterTex;
// uniform vec4 u_ScreenParams;
uniform float width;
uniform float height;
uniform float uniAlpha;

vec4 lm_take_effect_filter(sampler2D filterTex,vec4 inputColor,float uniAlpha)
{
    highp vec4 textureColor=inputColor;
    highp float blueColor=textureColor.b*63.;
    
    highp vec2 quad1;
    quad1.y=floor(floor(blueColor)/8.);
    quad1.x=floor(blueColor)-(quad1.y*8.);
    
    highp vec2 quad2;
    quad2.y=floor(ceil(blueColor)/8.);
    quad2.x=ceil(blueColor)-(quad2.y*8.);
    
    highp vec2 texPos1;
    texPos1.x=(quad1.x*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.r);
    texPos1.y=(quad1.y*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.g);
    
    highp vec2 texPos2;
    texPos2.x=(quad2.x*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.r);
    texPos2.y=(quad2.y*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.g);
    
    vec4 newColor1=texture2D(filterTex,texPos1);
    vec4 newColor2=texture2D(filterTex,texPos2);
    vec4 newColor=mix(newColor1,newColor2,fract(blueColor));
    newColor=mix(textureColor,vec4(newColor.rgb,textureColor.w),uniAlpha);
    
    return newColor;
}

void main()
{
    vec4 inputColor = texture2D(inputTex, uv0);
    inputColor = mix(inputColor, lm_take_effect_filter(filterTex, inputColor, 1.), uniAlpha);
    vec2 baseTextureSize= vec2(width, height);
    vec2 sucaiSize=vec2(1080,1080);
    vec2 fullBlendAnchor=baseTextureSize*.5;
    float scale=1.;
    float baseAspectRatio=baseTextureSize.y/baseTextureSize.x;
    float blendAspectRatio=sucaiSize.y/sucaiSize.x;
    if(baseAspectRatio>=blendAspectRatio){
        scale=baseTextureSize.y/sucaiSize.y;
    }else{
        scale=baseTextureSize.x/sucaiSize.x;
    }
    vec2 baseTextureCoord=uv0*baseTextureSize;
    float sizeIntensity = 0.;
    vec2 tempSucaiUV=(baseTextureCoord-fullBlendAnchor)/(sucaiSize*scale * (sizeIntensity + 1.))+vec2(.5);
    tempSucaiUV.y = 1.0-tempSucaiUV.y;

    vec4 oriColor = texture2D(inputImageTex, uv0);
    vec4 blendColor = texture2D(_MainTex, tempSucaiUV);
    vec4 resultColor = 1. - (1. - inputColor) * (1. - blendColor);
    gl_FragColor = resultColor;
}