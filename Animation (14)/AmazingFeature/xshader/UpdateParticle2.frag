precision highp float;
varying vec2 uv;
uniform sampler2D inputTexture1;
uniform sampler2D inputTexture2;
uniform sampler2D u_flowTex;
uniform float u_flowScale;
uniform float u_isStatic;
uniform vec2 u_frameSize;
uniform float u_flowSpeed;

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
    vec4 lastState1 = texture2D(inputTexture1, uv);
    vec4 lastState2 = texture2D(inputTexture2, uv);
    vec2 newPos = lastState1.xy;
    float life = lastState2.x;

    vec2 lastPosSize = newPos;//texture2D(inputTexture2, uv);
    vec2 speed = decodeFlowDir(lastState2.yz);
    vec4 flowValue = texture2D(u_flowTex, vec2(lastPosSize.x, 1.0-lastPosSize.y));
    flowValue = (flowValue * 255.0 / 10.0 - 15.0);
    flowValue *= u_flowScale;
    flowValue *= (1.0-u_isStatic);
    vec2 flowDir = vec2(flowValue.x, -flowValue.y);
    float flowStrength = abs(flowValue.x) + abs(flowValue.y);
    
    if (flowStrength > 10.0 && u_isStatic < 0.5) {
        flowDir *= 3.0;
        flowDir *= u_flowSpeed;
        if (flowStrength > 30.0) {
            flowDir *= 30.0 / max(abs(flowDir.x), abs(flowDir.y));
        }

        flowDir /= u_frameSize;
        speed = mix(speed, flowDir, 0.15);
    } else {
        speed *= 0.95;
    }


    vec4 newState = vec4(
        life - 1.0/255.0, encodeFlowDir(speed), 1.0
    );

    // newState.yz = encodeFlowDir(vec2(0.01, 0.0));

    // if (newPos.x < 1.0/255.0 || newPos.x > 254.0/255.0 || newPos.y < 1.0/255.0 || newPos.y > 254.0/255.0) {
    //     newState.r = 0.0;
    // }
    if (newPos.x < 0. || newPos.x > 1. || newPos.y < 0. || newPos.y > 1.) {
        newState.r = 0.0;
    }
    // newState.r = 0.5;

    gl_FragColor = newState;
}