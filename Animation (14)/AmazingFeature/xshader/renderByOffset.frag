precision highp float;

varying vec2 uv;
uniform sampler2D inputTexture1;  // input
uniform sampler2D inputTexture3;  // offset
uniform sampler2D inputTexture4;  // face mask
// uniform float iTime;
uniform float xStep;
uniform float yStep;
uniform float chromatismStrength;
uniform vec2 flowResolution;
uniform float offsetStrength;
uniform float faceOffsetStrength;

vec4 texture2Dmirror(sampler2D tex, vec2 uv) {
    // return texture2D(tex, uv);
    uv = mod(uv, 2.0);
    uv = mix(uv, 2.0 - uv, step(vec2(1.0), uv));
    return texture2D(tex, fract(uv));
}


void main()
{

    float useFace = 1.0;
    // useFace = 0.0; // debug: noface

    vec4 offsetUV = texture2Dmirror(inputTexture3, uv);
    offsetUV *= offsetStrength;
    offsetUV.y *= -1.0;
    float faceMask = texture2Dmirror(inputTexture4, vec2(uv.x, 1.0-uv.y)).r;
    faceMask *= useFace; 
    offsetUV *= (1.0 - min(faceMask, 1.0) * (1.0-faceOffsetStrength));

    
    vec2 finalUV = uv+offsetUV.xy;
    // finalUV = uv; // debug: no offset

    float offsetFaceMask = texture2Dmirror(inputTexture4, vec2(finalUV.x, 1.0-finalUV.y)).r;
    offsetFaceMask *= useFace;
    offsetUV *= (1.0 - min(offsetFaceMask, 1.0) * (1.0-faceOffsetStrength));

    vec4 textColor0 = texture2Dmirror(inputTexture1, finalUV);
    vec2 diff = offsetUV.xy * chromatismStrength;
    textColor0.g = texture2Dmirror(inputTexture1, finalUV+diff/2.0).g;
    textColor0.b = texture2Dmirror(inputTexture1, finalUV+diff).b;

    // float offsetColor = abs(offsetUV.x)+abs(offsetUV.y);
    // offsetColor *= 10.0;
    // textColor0 = vec4(offsetColor, 0., 0.0, 1.0);
 
    gl_FragColor = textColor0;
    
}