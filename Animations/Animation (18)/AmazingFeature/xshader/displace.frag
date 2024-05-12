precision highp float;

uniform sampler2D u_base;
uniform sampler2D u_mask;
uniform vec4 u_intensity_x;
uniform vec4 u_intensity_y;
uniform vec2 u_step;
uniform float u_intensity;

varying vec2 v_uv;
varying vec2 v_uv1;


vec3 unpremultiply (vec3 color, float alpha) {
    return color / (alpha + 0.0001);
}

vec4 texture2Dmirror (sampler2D tex, vec2 uv) {
    uv = mod(uv, 2.0);
    uv = mix(uv, 2.0 - uv, step(vec2(1.0), uv));
    return texture2D(tex, fract(uv));
}

void main() {
    vec4 mask = texture2D(u_mask, v_uv1);
    vec2 uv = vec2(v_uv.x + dot(mask, u_intensity_x), v_uv.y + dot(mask, u_intensity_y));
    vec4 base = texture2Dmirror(u_base, uv);

    vec4 mask1 = texture2D(u_mask, v_uv1 - u_step);
    float diff = (mask.a - mask1.a) * 0.7;
    mask1 = vec4(0.5 + vec3(diff * u_intensity), 1.0) * abs(diff);
    base = mask1 + base * (1.0 - mask1.a);

//    vec3 rgb = unpremultiply(base.rgb, base.a);
//    rgb += vec3(diff * u_intensity) * abs(diff);
//    base = vec4(rgb, 1.0) * base.a;

    gl_FragColor = base;
}
