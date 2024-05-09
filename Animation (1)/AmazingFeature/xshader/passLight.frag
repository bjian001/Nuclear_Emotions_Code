precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTex;
uniform vec2 scale;
vec3 grayFactor = vec3(76.5/255.0, 150.0/255.0, 28.5/255.0);
uniform float lightLight;
uniform float lightDark;
uniform float lightIns;
uniform float darkIns;
uniform float darkAdjust;

float uvProtect(vec2 uv)
{
    return step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
}
void main()
{
    float u_ThresholdLight = 10.;
    vec2 uv1 = (uv0 - .5) / scale + .5;
    vec4 inputColor = texture2D(inputTex, uv1) * uvProtect(uv1);
    float gray = dot(inputColor.rgb, grayFactor);
    vec4 lightColor = inputColor * (1. - step(u_ThresholdLight / 255.0, gray));
    float flag;
    float mylight=lightLight;
    if(mylight>0.){
        mylight*=lightIns;
        flag=1.0+mylight;
    }
    else{
        mylight*=darkIns;
        flag= 1.0/(1.0-mylight);
        lightColor.rgb-=abs(lightLight)*0.005*darkAdjust;
    }
    lightColor = vec4(clamp(1.0-pow(1.-lightColor.rgb,vec3(flag)),0.0,1.0),lightColor.a);

    float u_ThresholdDark = 180.;
    // vec2 uv1 = (uv0 - .5) / scale + .5;
    // vec4 inputColor = texture2D(inputTex, uv1) * uvProtect(uv1);
    // float gray = dot(inputColor.rgb, grayFactor);
    vec4 darkColor = inputColor * step(u_ThresholdDark / 255.0, gray);
    // float flag;
    mylight=lightDark;
    if(mylight>0.){
        mylight*=lightIns;
        flag=1.0+mylight;
    }
    else{
        mylight*=darkIns;
        flag= 1.0/(1.0-mylight);
        darkColor.rgb-=abs(lightDark)*0.005*darkAdjust;
    }
    darkColor = vec4(clamp(1.0-pow(1.-darkColor.rgb,vec3(flag)),0.0,1.0),darkColor.a);

    vec4 resultColor = lightColor;
    resultColor.rgb = mix(resultColor.rgb, clamp(darkColor.rgb / darkColor.a, 0., 1.), darkColor.a);
    resultColor.a = max(lightColor.a, darkColor.a);
    gl_FragColor = resultColor;
}
