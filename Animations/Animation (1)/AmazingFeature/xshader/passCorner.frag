precision highp float;
varying highp vec2 uv0;
uniform sampler2D inputTex;
uniform sampler2D cornerTex;



// overlay
float blendOverlay(float base, float blend) {
    return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}
 
vec3 blendOverlay(vec3 base, vec3 blend) {
    return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
}

void main()
{

    vec4 inputColor = texture2D(inputTex, uv0);
    vec4 cornerColor = texture2D(cornerTex, vec2(uv0.x, 1. - uv0.y));
    vec4 resultColor = inputColor;
    resultColor.rgb = blendOverlay(resultColor.rgb, cornerColor.rgb);
    gl_FragColor = resultColor;

}