precision highp float;
uniform sampler2D srcTex;
varying highp vec2 blurCoordinates[9];
const lowp vec3 rgb2gray = vec3(0.2125, 0.7154, 0.0721);

vec3 ApplyTemplate(mat3 Template, vec3 src[9]){//"template" is a reserved word, so "Template" used here
    vec3 result = Template[0][0] * src[0] + Template[0][1] * src[1] + Template[0][2] * src[2]
            + Template[1][0] * src[3] + Template[1][1] * src[4] + Template[1][2] * src[5]
            + Template[2][0] * src[6] + Template[2][1] * src[7] + Template[2][2] * src[8];
    return result;
}

float Sobel(vec3 src[9], float threshold){
    mat3 SobelTemplateX = mat3(-1., 0., 1.,
                                -2., 0., 2.,
                                -1., 0., 1);                            
    mat3 SobelTemplateY = mat3(-1., -2., -1.,
                                0., 0., 0.,
                                1., 2., 1.);
    vec3 SobelX;
    vec3 SobelY;
    SobelX = ApplyTemplate(SobelTemplateX, src);
    SobelY = ApplyTemplate(SobelTemplateY, src);
    // return step(threshold, abs(dot(SobelX,rgb2gray))+ abs(dot(SobelY,rgb2gray)));
    return abs(dot(SobelX,rgb2gray))+ abs(dot(SobelY,rgb2gray));
    //not considered eye sensitivity difference to rgb
    //return step(threshold, abs(dot(SobelX,vec3(0.33)))+ abs(dot(SobelY,vec3(0.33))));
}

float Prewitt(vec3 src[9],float threshold){
    mat3 PrewittTemplateX = mat3(-1., 0., 1.,
                                -1., 0., 1.,
                                -1., 0., 1);                            
    mat3 PrewittTemplateY = mat3(-1., -1., -1.,
                                0., 0., 0.,
                                1., 1., 1.);
    vec3 PrewittX;
    vec3 PrewittY;
    PrewittX = ApplyTemplate(PrewittTemplateX, src);
    PrewittY = ApplyTemplate(PrewittTemplateY, src);
    return step(threshold, abs(dot(PrewittX,rgb2gray))+ abs(dot(PrewittY,rgb2gray)));
    //not considered eye sensitivity difference to rgb
    // return step(threshold, abs(dot(PrewittX,vec3(0.33)))+ abs(dot(PrewittX,vec3(0.33))));
}

float Roberts(vec3 src[9], float threshold){
    mat3 RobertsTemplateX = mat3(0., 0., 0.,
                                0., -1., 0.,
                                0., 0., 1);                            
    mat3 RobertsTemplateY = mat3(0., 0., 0.,
                                0., 0., -1.,
                                0., 1., 0.);
    vec3 RobertsX;
    vec3 RobertsY;
    RobertsX = ApplyTemplate(RobertsTemplateX, src);
    RobertsY = ApplyTemplate(RobertsTemplateY, src);
    return step(threshold, abs(dot(RobertsX,rgb2gray))+ abs(dot(RobertsY,rgb2gray)));
    //not considered eye sensitivity difference to rgb
    // return = step(threshold, abs(dot(RobertsX,vec3(0.33)))+ abs(dot(RobertsY,vec3(0.33))));
}

float Laplacian4(vec3 src[9], float laplacianThreshold){
    mat3 Laplacian4Template = mat3(0., -1., 0.,
                                    -1., 4., -1.,
                                    0., -1., 0.);
    vec3 Laplacian;
    Laplacian = ApplyTemplate(Laplacian4Template, src);
    return step(abs(dot(Laplacian, rgb2gray)),laplacianThreshold);
    //not considered eye sensitivity difference to rgb
    //return step(abs(dot(Laplacian, vec(0.33))) + abs(dot(Laplacian, vec(0.33))),laplacianThreshold);
}

float Laplacian8(vec3 src[9], float laplacianThreshold){
    mat3 Laplacian8Template = mat3(-1., -1., -1.,
                                    -1., 8., -1.,
                                    -1., -1., -1.);
    vec3 Laplacian;
    Laplacian = ApplyTemplate(Laplacian8Template, src);
    return step(abs(dot(Laplacian, rgb2gray)),laplacianThreshold);
    //not considered eye sensitivity difference to rgb
    //return step(abs(dot(Laplacian, vec(0.33))) + abs(dot(Laplacian, vec(0.33))),laplacianThreshold);
}

void main() {
    vec3 src[9];
    src[0] = texture2D(srcTex, blurCoordinates[0]).rgb;
    src[1] = texture2D(srcTex, blurCoordinates[1]).rgb;
    src[2] = texture2D(srcTex, blurCoordinates[2]).rgb;
    src[3] = texture2D(srcTex, blurCoordinates[3]).rgb;
    src[4] = texture2D(srcTex, blurCoordinates[4]).rgb;
    src[5] = texture2D(srcTex, blurCoordinates[5]).rgb;
    src[6] = texture2D(srcTex, blurCoordinates[6]).rgb;
    src[7] = texture2D(srcTex, blurCoordinates[7]).rgb;
    src[8] = texture2D(srcTex, blurCoordinates[8]).rgb;

    float threshold = 0.4;
    float g = 0.;
    //Sobel operator
    g = Sobel(src, threshold);

    //Prewitt operator
    //g = Prewitt(src,threshold);

    //Roberts operator
    //g = Roberts(src, threshold);

    float laplacianThreshold = .01;
    //4-neighborhood Laplacian operator
    //g = Laplacian4(src, laplacianThreshold);

    //8-neighborhood Laplacian operator
    //g = Laplacian8(src, laplacianThreshold);

    gl_FragColor = vec4(g, g, g, texture2D(srcTex, blurCoordinates[4]).a);
    vec3 tempColor = g * src[4] * src[4];
    gl_FragColor.rgb = tempColor;
}
