precision highp float;

varying vec2 uv;
uniform sampler2D inputImageTexture;
uniform int inputWidth;
uniform int inputHeight;
uniform float blurSize;

void main()
{
    vec2 screenSize = vec2(inputWidth,inputHeight);
    float adaptFactor = min(screenSize.x, screenSize.y)/1080.0; // 1080p adaptation
    float imageWidthReciprocal = 1.0/screenSize.x*adaptFactor;
    float imageHeightReciprocal = 1.0/screenSize.y*adaptFactor;

    const int  radius = 8;
    float half_gaussian_weight[9];
    
    half_gaussian_weight[0]= 0.20;
    half_gaussian_weight[1]= 0.19;
    half_gaussian_weight[2]= 0.17;
    half_gaussian_weight[3]= 0.15;
    half_gaussian_weight[4]= 0.13;
    half_gaussian_weight[5]= 0.11;
    half_gaussian_weight[6]= 0.08;
    half_gaussian_weight[7]= 0.05;
    half_gaussian_weight[8]= 0.02;
    
    vec4 sum            = vec4(0.0);
    vec4 result         = vec4(0.0);
    vec2 unit_uv        = vec2(imageWidthReciprocal,imageHeightReciprocal)*blurSize*1.25;
    vec4 curColor       = texture2D(inputImageTexture, uv);
    vec4 centerPixel    = curColor*half_gaussian_weight[0];
    
    float sum_weight    = half_gaussian_weight[0];
    //horizontal
    for(int i=1;i<=radius;i++)
    {
        vec2 curRightCoordinate = uv+vec2(float(i),0.0)*unit_uv;
        vec2 curLeftCoordinate  = uv+vec2(float(-i),0.0)*unit_uv;
        vec4 rightColor = texture2D(inputImageTexture,curRightCoordinate);
        vec4 leftColor = texture2D(inputImageTexture,curLeftCoordinate);
        sum+=rightColor*half_gaussian_weight[i];
        sum+=leftColor*half_gaussian_weight[i];
        sum_weight+=half_gaussian_weight[i]*2.0;
    }
    
    result = (sum+centerPixel)/sum_weight; 
    // result.a = 1.0;
    result.a = curColor.a;
    gl_FragColor = result;
}
