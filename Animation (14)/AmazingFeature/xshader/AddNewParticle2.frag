precision highp float;

uniform sampler2D u_flowTex;
uniform sampler2D u_particleAttrTex1;
uniform sampler2D u_particleAttrTex2;
uniform float u_FPS;
uniform float u_maxLife;
uniform float u_flowScale;
uniform vec2 u_randSeed;
uniform float u_threshold;
uniform float u_isStatic;
uniform int u_isFirstFrame;
uniform float u_emmiterRateRatio;
uniform vec2 u_avgABSFlow;
uniform float u_needAdd;
uniform vec2 u_frameSize;
uniform vec2 u_randomDir;
uniform float u_flowSpeed;
varying vec2 v_particleAttrCoord;
varying vec2 v_flowCoord;
varying float v_randStatic;
varying float v_randRate;
varying vec2 v_randSpeedVal;

vec2 encodeFlowDir(vec2 oriFlowDir) {
    vec2 res = (oriFlowDir + 15.0/u_frameSize) * 10.0;
    return res;
}

vec2 decodeFlowDir(vec2 oriFlowDir) {
    vec2 res = oriFlowDir / 10.0 - 15.0/u_frameSize;
    return res;
}


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
    float th = u_threshold;
    float rate = u_emmiterRateRatio;
    th = (u_avgABSFlow.x + u_avgABSFlow.y) * 3.0;
    th = max(u_threshold, th);

    if (u_isStatic > 0.5 && v_randStatic < 0.001) {
        flowStrength = th + 10.0;
    }

    vec4 res = attrValue2;
    if (flowStrength > th) {
        if (life < 1.0) { 
            // set flow direction
            vec2 flowDir = vec2(flowValue.x, -flowValue.y);
            flowDir *= 3.0 * u_flowSpeed;
            // flowDir = clamp(flowDir, -50.0, 50.0);
            if (flowStrength > 30.0) {
                flowDir *= 30.0 / max(abs(flowDir.x), abs(flowDir.y));
            }
            flowDir /= u_frameSize;
            flowDir = mix(flowDir, u_randomDir, float(u_isStatic));
            flowDir += v_randSpeedVal;


            res = vec4(u_FPS*u_maxLife*u_needAdd/255.0, encodeFlowDir(flowDir), 1.);
        } else {
            res = attrValue2;
        }
    } 
    // res.yz = encodeFlowDir(vec2(0.01, 0.0));
    // res = vec4(0.5, 0.0, 0.0, 1.0);
    gl_FragColor = res;
}