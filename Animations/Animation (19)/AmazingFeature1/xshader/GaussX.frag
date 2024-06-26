precision highp float;

varying vec2 uv;
uniform sampler2D inputImageTexture;
uniform int inputWidth;
uniform int inputHeight;
uniform float blurSize;
uniform int blurRadius;

#define textureCoordinate uv

float setMaskVal(vec4 color,vec3 weight)
{
    if(dot(color.rgb,weight)>0.5)
        return 0.0;             
    else
        return 1.0;
}

void main()
{
    vec2 screenSize = vec2(inputWidth,inputHeight);
    vec3 W = vec3(0.299,0.587,0.114);

    float half_gaussian_weight[9];
    
    half_gaussian_weight[0]= 0.20;//0.137401;
    half_gaussian_weight[1]= 0.19;//0.125794;
    half_gaussian_weight[2]= 0.17;//0.106483;
    half_gaussian_weight[3]= 0.15;//0.080657;
    half_gaussian_weight[4]= 0.13;//0.054670;
    half_gaussian_weight[5]= 0.11;//0.033159;
    half_gaussian_weight[6]= 0.08;//0.017997;
    half_gaussian_weight[7]= 0.05;//0.008741;
    half_gaussian_weight[8]= 0.02;//0.003799;
    
    
    vec4 sum            = vec4(0.0);
    vec4 result         = vec4(0.0);
    vec2 unit_uv        = vec2(blurSize/screenSize.x,blurSize/screenSize.y)*1.25;
    vec4 curColor       = texture2D(inputImageTexture, textureCoordinate);
    curColor.a = setMaskVal(curColor,W);
    vec4 centerPixel    = curColor*half_gaussian_weight[0];
    
    float sum_weight    = half_gaussian_weight[0];
    //horizontal
    for(int i=1;i<=32;i++)
    {
        if(blurRadius<i){
            break;
        }
        vec2 curRightCoordinate = textureCoordinate+vec2(float(i),0.0)*unit_uv;
        vec2 curLeftCoordinate  = textureCoordinate+vec2(float(-i),0.0)*unit_uv;
        vec4 rightColor = texture2D(inputImageTexture,curRightCoordinate);
        vec4 leftColor = texture2D(inputImageTexture,curLeftCoordinate);
        rightColor.a = setMaskVal(rightColor,W);
        leftColor.a = setMaskVal(leftColor,W);
        sum+=rightColor*half_gaussian_weight[i];
        sum+=leftColor*half_gaussian_weight[i];
        sum_weight+=half_gaussian_weight[i]*2.0;
    }
    
    result = (sum+centerPixel)/sum_weight; 
    // result.a = 1.0;

    gl_FragColor = result + centerPixel * 2.;
    gl_FragColor.a = curColor.a;
}
