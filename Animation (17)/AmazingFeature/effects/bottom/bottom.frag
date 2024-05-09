precision highp float;

varying vec2 uv0;

uniform sampler2D inputTex;
uniform vec2 u_ScreenParams;
uniform float scale_value;
uniform float radial_blur_number;
uniform float iTime;
uniform float turbulent_number;
uniform vec2 turbulent_offset;

vec2 ScaleFunc(vec2 _u){
    return (_u-0.5)/scale_value+0.5;
}

float random(vec2 st)
{
    return fract(sin(dot(st.xy, vec2(123.98,783.33))) * 48.59);
}

vec2 random2(vec2 st)
{
    st = vec2(
        dot(st, vec2(12.1, 11.7)),
        dot(st, vec2(26.5, 13.3)));
    return fract(sin(st)*43.5413) * 2.0 - 1.0;
}

float noise(vec2 st)
{
    vec2 i = floor(st);  // integer
    vec2 f = fract(st);  // fraction 0-1

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation
    vec2 u = smoothstep(0.0, 1.0, f);

    // Mix 4 corners percentages
    float n = mix(
        mix(
            dot(random2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
            dot(random2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)),
            u.x),
        mix(
            dot(random2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
            dot(random2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)),
            u.x),
        u.y
    );

    return n;
}

mat2 rotate2d(float angle){
    return mat2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}


vec4 radial_blur(vec2 _u)
{
	const int samples = 15;    
    vec4 col = vec4(0);
    vec2 uv = _u;
    for (int i = 0; i < samples; i++) //operating at 2 samples for better performance
    {
        col += texture2D(inputTex,(uv-0.5)*mix(1., radial_blur_number, float(i)/float(samples))+0.5);
        col += texture2D(inputTex,(uv-0.5)*mix(1., 1./radial_blur_number, float(i)/float(samples))+0.5);
    }
    return col/float(samples*2);
}

float cut(vec2 _u){
    return step(0., _u.x) * step(_u.x, 1.) * step(0., _u.y) * step(_u.y, 1.);
}

void main()
{
    vec2 uv1 = uv0;
    vec4 res = radial_blur(ScaleFunc(uv1));

    float noise_scale = 3.0;
    vec2 noise2d = vec2(noise((uv0+turbulent_offset*0.0008)*noise_scale), noise((uv0+turbulent_offset*0.0008)*noise_scale+987.0));
    vec2 turbulence = noise2d * turbulent_number;
    turbulence.x *= 1.-smoothstep(0., 0.25, uv0.x) * smoothstep(1., 0.75, uv0.x);
    turbulence.y *= 1.-smoothstep(0., 0.25, uv0.y) * smoothstep(1., 0.75, uv0.y);
    res = texture2D(inputTex, uv1 + turbulence * 0.1);
    res = radial_blur(ScaleFunc(uv1) + turbulence * 0.002);
    // res = radial_blur(uv1);

    // res = texture2D(inputTex, ScaleFunc(uv1) + turbulence * 0.0005);
    // res = vec4(turbulence, 0,1);
    // res = texture2D(inputTex, uv1);
    gl_FragColor = res;
}
