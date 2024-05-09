precision highp float;

uniform sampler2D u_flowTex;
uniform sampler2D u_particleAttrTex1;
uniform sampler2D u_particleAttrTex2;
uniform sampler2D u_particleTex;
uniform int u_isFirstFrame;
uniform float u_flowScale;
uniform float u_threshold;
uniform float u_emmiterRateRatio;
uniform vec2 u_avgABSFlow;
uniform float u_isStatic;
uniform vec2 u_randomPos;
varying vec2 v_particleAttrCoord;
varying vec2 v_flowCoord;
varying float v_randStatic;
varying float v_randRate;
varying vec2 v_randPosOffset; 
uniform vec2 u_frameSize;


void main()
{
    vec4 flowValue = texture2D(u_flowTex, vec2(v_flowCoord.x, 1.0-v_flowCoord.y));
    flowValue = (flowValue * 255.0 / 10.0 - 15.0);
    flowValue *= u_flowScale;
    flowValue *= (1.0-u_isStatic);
    vec4 attrValue1 = texture2D(u_particleAttrTex1, v_particleAttrCoord);
    vec4 attrValue2 = texture2D(u_particleAttrTex2, v_particleAttrCoord);
    attrValue1 = mix(attrValue1, vec4(0.0, 0.0, 0.0, 0.0), float(u_isFirstFrame));
    attrValue2 = mix(attrValue2, vec4(0.0, 0.0, 0.0, 0.0), float(u_isFirstFrame));

    float flowStrength = abs(flowValue.x) + abs(flowValue.y);
    float life = attrValue2.r * 255.0;
    // float particleNum = 0.0;
    float th = u_threshold;
    float rate = u_emmiterRateRatio;
    th = (u_avgABSFlow.x + u_avgABSFlow.y) * 3.0;
    th = max(u_threshold, th);

    if (u_isStatic > 0.5 && v_randStatic < 0.001) {
        flowStrength = th + 10.0;
    }
    
    // if (u_isFirstFrame == 0) {
    //     vec4 particleValue = texture2D(u_particleTex, v_flowCoord);
    //     particleNum = particleValue.z;
    //     if (particleNum > 5.0) {
    //         rate = 0.1;
    //     }
    // }

    vec4 res = attrValue1;
    if (flowStrength > th && v_randRate <= rate) {
        if (life < 1.0) {
            // set position
            vec2 flowPos = mix(v_flowCoord, u_randomPos, float(u_isStatic));
            flowPos += v_randPosOffset;

            res = vec4(flowPos, 0., 0.); 
        } else { 
            res = attrValue1;
        }
    }

    // res = vec4(0.5, 0.5, 0.01, 0.0);


    gl_FragColor = res;
}