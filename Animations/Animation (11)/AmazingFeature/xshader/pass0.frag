precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D filterImageTexture;
varying vec2 uv;

uniform int inputWidth;
uniform int inputHeight;

uniform float iTime;
uniform float scale;
uniform float lightIns;
uniform float shakeMask;
uniform float filterHow;
float remap(float a1,float a2,float t1,float t2,float t){
    return mix(a1,a2,(t-t1)/(t2-t1));
}
float TimeScale(float t)
{
    
    if(t<0.3)return remap(1.0,scale,0.0,0.3,t);
    else if(t<0.6)return remap(scale,1.0,0.3,0.6,t);
    return 1.0;
}
vec4 takeEffectFilter(sampler2D FilterTex, vec4 inputColor,float how)
{
    highp float blueColor=inputColor.b*63.;
  
    highp vec2 quad1;
    quad1.y=floor(floor(blueColor)/8.);
    quad1.x=floor(blueColor)-(quad1.y*8.);
  
    highp vec2 quad2;
    quad2.y=floor(ceil(blueColor)/8.);
    quad2.x=ceil(blueColor)-(quad2.y*8.);
  
    highp vec2 texPos1;
    texPos1.x=(quad1.x*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.r);
    texPos1.y=(quad1.y*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.g);
  
    highp vec2 texPos2;
    texPos2.x=(quad2.x*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.r);
    texPos2.y=(quad2.y*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.g);
  
    lowp vec4 newColor1=texture2D(FilterTex,texPos1);
    lowp vec4 newColor2=texture2D(FilterTex,texPos2);
    lowp vec4 newColor=mix(newColor1,newColor2,fract(blueColor));
    newColor = mix(inputColor,vec4(newColor.rgb,inputColor.a),how);
    return newColor;
}
void main()
{
    float dis=clamp(shakeMask-abs(length(uv-0.5)-0.2),0.,1.);//0.5*sqrt(2)=0.7071067
    float myTimeScale=TimeScale(iTime);
    vec2 newUV = (uv-0.5)*mix(1.0,myTimeScale,dis)+0.5;
    newUV.x+=sin(newUV.y*16.)/myTimeScale*dis*0.01;
    newUV.y+=sin(newUV.x*9.)/myTimeScale*dis*0.007;
    vec4 newCol = texture2D(inputImageTexture, newUV);

    // vec3 changedCol=takeEffectFilter
    newCol.rgb=takeEffectFilter(filterImageTexture,newCol,filterHow).rgb;
    newCol.rgb*=lightIns;
    //newCol.rgb = newCol.rgb*(1.0+filterHow*changFlag);
    

    vec4 col = texture2D(inputImageTexture, uv);
    float mixFlag=abs(0.3-iTime)*3.0303;
    if(mixFlag>1.)mixFlag=1.;
    col.rgb=mix(col.rgb,newCol.rgb,smoothstep(0.0,1.0,1.0-mixFlag));
    gl_FragColor = vec4(col);
}
