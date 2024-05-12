precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform float radius;
uniform float angle;
uniform vec2 scale;
uniform float screenW;
uniform float screenH;
uniform vec2 center;
uniform vec2 offset;

vec4 lm_twirl(sampler2D tex,vec2 uv,vec2 center, float radius,float angle)
{
    vec2 tc=uv;
    tc-=center;
    float ratio = screenH / screenH;
    if (ratio < 1.) tc.x *= ratio;
    else tc.y /= ratio;
    float dist=length(tc);
    radius *= mix(1., 1.25, smoothstep(0., .45, 16. / 9. / max(ratio, 1. / ratio) - 1.));
    if(dist<radius)
    {
        float percent= dist / (radius);
        percent = smoothstep(0., 1., percent);
        percent = 1. - percent;
        float theta = percent*radians(angle);
        float s=sin(theta);
        float c=cos(theta);
        
        tc=vec2(dot(tc,vec2(c,-s)),dot(tc,vec2(s,c)));
    }
    if (ratio < 1.) tc.x /= ratio;
    else tc.y *= ratio;
    tc+=center;
    tc -= offset;
    tc = (tc - .5) / scale + .5;
    vec4 resultColor=texture2D(tex,tc) * step(tc.x, 1.) * step(tc.y, 1.) * step(0., tc.x) * step(0., tc.y);
    return resultColor;
}

void main()
{
    gl_FragColor = lm_twirl(u_albedo, uv0, center, radius / 100., angle);
}
