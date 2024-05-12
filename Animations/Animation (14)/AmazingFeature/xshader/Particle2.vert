precision highp float;

attribute vec3 position;
attribute vec2 texcoord0;
uniform sampler2D u_particleAttrTex1;
uniform sampler2D u_particleAttrTex2;
uniform float u_flowSizeDecrease;
uniform float u_maxLife;
uniform float u_FPS;
uniform float u_maxParticleSize;
uniform float u_sizeSplitPoint;
uniform float u_particleRatio;
varying vec2 v_texCoord;

vec2 convert_coord(vec2 coord) { // [0, 1] -> [-1, 1]
    vec2 res = vec2(2.0*coord.x-1.0, 2.0*coord.y-1.0);
    return res;
}

float calcSize(float weight) {
    float tmpWeight = weight;
    float res;

    float splitPart = u_sizeSplitPoint;
    if (tmpWeight < splitPart) {
        res = mix(20.0, u_maxParticleSize, tmpWeight/splitPart);
    } else {
        float w = (tmpWeight - splitPart)/(1.0-splitPart);
        w = clamp(w, 0.0, 1.0);
        w = pow(w, 0.5);
        res = mix(u_maxParticleSize, 10.0, w);
    }

    return res;
}

void main()
{
    v_texCoord  = texcoord0;// * uvTiling + uvOffset;
    gl_Position = vec4(position, 1.0);
    gl_PointSize = 50.0;

    vec4 particleAttr1 = texture2D(u_particleAttrTex1, texcoord0);
    vec4 particleAttr2 = texture2D(u_particleAttrTex2, texcoord0);
    vec2 pos = particleAttr1.xy;
    float life = particleAttr2.r*255.0;
    // pos = vec2(0.5);
    // life = 100.0;
    float weight = 1.0 - life / (u_FPS * u_maxLife);
    gl_Position.xy = vec2(convert_coord(pos));
    gl_PointSize = calcSize(weight);
    // gl_PointSize = 50.0;
    gl_PointSize *= u_particleRatio;
    if (life < 1e-4) {
        gl_Position = vec4(convert_coord(vec2(2.0, 2.0)), 0.0, 1.0);
        gl_PointSize = 0.0;
    }
}
