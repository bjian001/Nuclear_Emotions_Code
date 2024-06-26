precision highp float;

varying vec2 uv;

uniform sampler2D inputImageTexture;
uniform int inputWidth;
uniform int inputHeight;
uniform float blurSize;
uniform int blurRadius;
uniform float intensity;
#define textureCoordinate uv

void main()
{
    vec2 screenSize = vec2(inputWidth,inputHeight);

    float half_gaussian_weight[9];
    
    half_gaussian_weight[0]= 0.2; //0.2;//0.137401;
    half_gaussian_weight[1]= 0.19;//0.2;//0.125794;
    half_gaussian_weight[2]= 0.17;//0.2;//0.106483;
    half_gaussian_weight[3]= 0.15;//0.2;//0.080657;
    half_gaussian_weight[4]= 0.13;//0.2;//0.054670;
    half_gaussian_weight[5]= 0.11;//0.2;//0.033159;
    half_gaussian_weight[6]= 0.08;//0.2;//0.017997;
    half_gaussian_weight[7]= 0.05;//0.2;//0.008741;
    half_gaussian_weight[8]= 0.02;//0.2;//0.003799;
    
    vec4 sum            = vec4(0.0);
    vec4 result         = vec4(0.0);
    vec2 unit_uv        = vec2(blurSize/screenSize.x,blurSize/screenSize.y)*1.25;
    vec4 centerPixel    = texture2D(inputImageTexture, textureCoordinate)*half_gaussian_weight[0];
    float  sum_weight   = half_gaussian_weight[0];
    
    //vertical
    for(int i=1;i<=32;i++)
    {
        if(blurRadius<i){
            break;
        }
        vec2 curBottomCoordinate    = textureCoordinate+vec2(0.0,float(i))*unit_uv;
        vec2 curTopCoordinate       = textureCoordinate+vec2(0.0,float(-i))*unit_uv;
        sum+=texture2D(inputImageTexture,curBottomCoordinate)*half_gaussian_weight[i];
        sum+=texture2D(inputImageTexture,curTopCoordinate)*half_gaussian_weight[i];
        sum_weight+=half_gaussian_weight[i]*2.0;
    }
    
    result = (sum+centerPixel)/sum_weight;
    // result.a = 1.0;

    gl_FragColor = result + centerPixel * intensity;
    gl_FragColor.a = texture2D(inputImageTexture, textureCoordinate).a;
}
