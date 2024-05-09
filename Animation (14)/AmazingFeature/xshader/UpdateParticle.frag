precision highp float;
varying vec2 uv;
uniform sampler2D inputTexture1;
uniform sampler2D inputTexture2;
// uniform sampler2D u_flowTex;
// uniform float u_flowScale;
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

    vec2 pos = lastState1.xy;
    vec2 speed = decodeFlowDir(lastState2.yz);

    vec2 newPos = pos + speed;

    vec4 newState = vec4(
        newPos,
        0., 0.
    );
    
  

    gl_FragColor = newState;

}