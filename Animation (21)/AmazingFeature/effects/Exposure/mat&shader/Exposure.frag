precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_InputTex;
uniform float u_Intensity;
uniform float u_Alpha;
uniform float u_Offset;
uniform float u_GrayscaleCorrect;
uniform float use_linear_light;

void Exposure(inout vec4 col, float _intensity, float _offset, float _gray_scale_correct, float _linear){
    if(_linear<0.5) col.rgb = pow(col.rgb, vec3(2.2));
    col.rgb *= pow(2.0, _intensity);
    col.rgb += u_Offset;
    vec3 s = sign(col.rgb);
    col.rgb = pow(abs(col.rgb), vec3(1.0 / _gray_scale_correct)) * s;
    s = sign(col.rgb);
    if (_linear<0.5) col.rgb = pow(abs(col.rgb), vec3(0.454545454545)) * s;
}

void main()
{
    vec4 res = texture2D(u_InputTex, uv0); 
    Exposure(res, u_Intensity, u_Offset, u_GrayscaleCorrect, use_linear_light);
    gl_FragColor = res;
}
