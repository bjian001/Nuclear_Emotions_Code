precision highp float;

uniform sampler2D baseTex;  //bgTex
uniform sampler2D _MainTex; //modelTex
uniform float _alpha;

varying vec2 uv1;   //bgUV
varying vec2 uv0;   //modelUV

void main ()
{
    vec4 bgCol = texture2D(baseTex, uv1);
    vec4 modelCol = texture2D(_MainTex, uv0);
    vec3 col = bgCol.rgb * (1.0 - modelCol.a * _alpha) + modelCol.rgb * _alpha;
    gl_FragColor = vec4(col.rgb, max(bgCol.a, modelCol.a));
}

