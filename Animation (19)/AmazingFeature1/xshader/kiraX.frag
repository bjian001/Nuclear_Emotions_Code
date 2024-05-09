precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform float density;
uniform float samples;
uniform float ins;
uniform float R;
uniform float G;
uniform float B;
uniform float angleVal;
uniform float decay;
uniform int inputHeight;
uniform int inputWidth;
float hash(vec2 p) {
   return fract(sin(dot(p, vec2(41.0, 289.0)))*45758.5453);
}
void main()
{
    vec2 screen = vec2(inputWidth, inputHeight);
    float weight = 1.;
    vec2 uv = uv0;
    vec2 uv1 = uv0;
    vec2 ddir = vec2(-0.1, 0.5) * density / samples;
    vec4 col = vec4(0.0);

    // float angleVal = 0.1;
    vec2 angle = 0.1 / (angleVal / 5.) * vec2(-angleVal, -3.) * min(screen.x, screen.y) / screen;
    weight = 1.;
    ddir = angle * density / samples;
    uv += ddir * (hash(uv0) * 2. - 1.);
    uv1 = uv;
    for(int i = 0; i < 64; ++i)
    {
        if(int(samples)<i){
            break;
        }
        uv -= ddir;
        uv1 += ddir;
        float w = G * (2. - (samples - float(i)) / samples);
        w *= w;
        col += texture2D(u_albedo, uv).rgba * vec4(weight * R, weight * G, weight * B, weight);//left
        col += texture2D(u_albedo, uv1).rgba * vec4(weight * R, weight * G, weight * B, weight);//right
        weight *= decay;
    }
    vec4 inputColor = texture2D(u_albedo, uv0);
    col = sqrt(smoothstep(0.0, 1.0, col)) / sqrt((density + 0.001) * ins);
    gl_FragColor = clamp(col, vec4(0.), vec4(1.));
    gl_FragColor.a = inputColor.a;
}
