precision highp float;
varying highp vec2 uv0;

uniform sampler2D inputImageTexture;
uniform vec4 u_ScreenParams;
uniform sampler2D blurImageTexture;
uniform sampler2D maskImageTexture;
uniform sampler2D lightFilterTex;
uniform sampler2D mattingTex;
uniform sampler2D _MainTex;
uniform sampler2D lineTex;
uniform float maskType;
uniform float offsetY;
uniform float u_hueChange;
uniform float u_speed;
uniform float u_intensity;
uniform float lineSucaiIns;

vec4 takeEffectFilter(sampler2D myfilter,vec4 inputColor,float how)
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

    lowp vec4 newColor1=texture2D(myfilter,texPos1);
    lowp vec4 newColor2=texture2D(myfilter,texPos2);
    lowp vec4 newColor=mix(newColor1,newColor2,fract(blueColor));
    newColor = mix(inputColor,vec4(newColor.rgb,inputColor.w),how);
    return newColor;

}
vec2 flip_uv(vec2 uv)
{
    return abs(mod(uv + 1., 2.) - 1.0);
}
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z +  (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = flip_uv(uv0-vec2(0.0,offsetY));

    // veccol = 1.0 * texture2D(inputImageTexture, uv+vec2( 0.0*offset.x,  0.0*offset.y));
    vec4 blurCol = texture2D(blurImageTexture,uv);
    vec4 filterCol = takeEffectFilter(_MainTex,blurCol,1.0);
    vec4 mask = vec4(1.0);
    vec4 resultCol = texture2D(inputImageTexture, uv);
    vec4 col = resultCol;
    if(maskType < 0.5){//0
        vec4 lineCol = texture2D(lineTex,vec2(uv.x,1.0-uv.y));
        lineCol.rgb = clamp( lineCol.rgb/lineCol.a,0.0,1.0);
        resultCol =filterCol;

        resultCol.rgb = mix(filterCol.rgb,lineCol.rgb,lineCol.a*lineSucaiIns);
    }
    else if(maskType<1.5){//1
        mask = texture2D(maskImageTexture,uv);
        filterCol = takeEffectFilter(lightFilterTex,filterCol,1.0);
        vec3 hsv = rgb2hsv(filterCol.rgb);
        filterCol.rgb = hsv2rgb(hsv+vec3(u_hueChange,0.,0.));
        resultCol.r = mix(resultCol.r,filterCol.r,clamp(mask.r*1.0,0.0,1.0)*u_intensity);
        resultCol.g = mix(resultCol.g,filterCol.g,clamp(mask.g*1.0,0.0,1.0)*u_intensity);
        resultCol.b = mix(resultCol.b,filterCol.b,clamp(mask.b*1.0,0.0,1.0)*u_intensity);
    }else if(maskType<2.5){//2
        float gray = dot(blurCol.rgb,vec3(0.299 ,0.587,0.114));
        gray = (max(blurCol.r,max(blurCol.r,blurCol.b))+min(blurCol.r,min(blurCol.r,blurCol.b)))*0.5;
        float lowSmoothIns =36./255.;
        float hightSmoothIns = 13./255.;
        float lowIns = 50./255.;
        float hightIns = 205./255.;
        float grayMask = smoothstep(lowIns-lowSmoothIns,lowIns+lowSmoothIns,gray)
        *smoothstep(hightIns+hightSmoothIns,hightIns-hightSmoothIns,gray);
        mask = texture2D(mattingTex,vec2(uv.x,1.0-uv.y));
        filterCol = takeEffectFilter(_MainTex,blurCol,1.0);
        filterCol = takeEffectFilter(lightFilterTex,filterCol,1.0);
        vec3 hsv = rgb2hsv(filterCol.rgb);
        filterCol.rgb = hsv2rgb(hsv+vec3(u_hueChange,0.,0.0));
        resultCol.rgb = mix(resultCol.rgb,filterCol.rgb*1.0,(resultCol.rgb*0.8+0.2)*mask.r*grayMask*0.7*u_intensity);
        // resultCol = vec4(grayMask);
        // resultCol = mix(resultCol,filterCol,mask.r*0.7);
    }
    else {//3
        float gray = dot(blurCol.rgb,vec3(0.299 ,0.587,0.114));
        // gray = (max(blurCol.r,max(blurCol.r,blurCol.b))+min(blurCol.r,min(blurCol.r,blurCol.b)))*0.5;
        float lowSmoothIns =36./255.;
        float hightSmoothIns = 13./255.;
        float lowIns = 93./255.;
        float hightIns = 188./255.;
        float grayMask = smoothstep(lowIns-lowSmoothIns,lowIns+lowSmoothIns,gray)
        *smoothstep(hightIns+hightSmoothIns,hightIns-hightSmoothIns,gray);
        filterCol = takeEffectFilter(_MainTex,texture2D(maskImageTexture,uv),1.0);
        filterCol = takeEffectFilter(lightFilterTex,filterCol,1.0);
        vec3 hsv = rgb2hsv(filterCol.rgb);
        filterCol.rgb = hsv2rgb(hsv+vec3(u_hueChange,0.,0.));
        
        resultCol = mix(resultCol,filterCol,grayMask*u_intensity);
    }
    

    
    

    gl_FragColor = vec4(resultCol);
    
}