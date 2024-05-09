precision highp float;

varying vec2 v_texCoord;
uniform float u_maxLife;
uniform float u_FPS;
uniform float u_isMiddleLowDevice;

uniform vec2 frameResolution;

vec4 RenderUV(vec2 uv)
{
    float A = mix(20.0, 40.0, u_isMiddleLowDevice);
    float B = 0.0012;
    float C = 0.0;
    float circle_size = 3.0;
    float T = 5233.33;
    // float R = (circle_size+0.5)*T-C; // R=15.7
    // R = ceil(R);
    float R = 18317.0;
    
    // vec2 center_pos_norm = vec2(0.5, 0.5);
    // vec2 center_pos = vec2(center_pos_norm.x*R*2.0, center_pos_norm.y*R*2.0); // (R, R)
    vec2 center_pos = vec2(R, R);
    vec2 cur_pos = vec2(uv.x*R*2.0, uv.y*R*2.0);

    vec2 dis = cur_pos - center_pos;

    float theta = atan(dis.y/(dis.x+1e-6));
    if (dis.x < 0.0) {
        theta += 3.14; 
    }
    float r = length(dis);

    float r1 = r;
    float alpha = 0.0;
    if ((r+C) >= circle_size*T && (r+C) <= (circle_size+0.5)*T) {
        r1 = r + A*sin(B*(r+C));
        alpha = 1.0;
    } 
    else if ((r+C) >= circle_size*T/2.0 && (r+C) <= (circle_size+0.5)*T/2.0) {
        r1 = mix(r1, r + A*sin(B*(r+C)), u_isMiddleLowDevice);
        alpha = 1.0;
    } 
    else {
        alpha = 1.0;
        // discard;
        return vec4(0.0, 0.0, 0.0, 1.0);
    }
    vec2 dst_pos;
    dst_pos.x = center_pos.x + r1*cos(theta);
    dst_pos.y = center_pos.y + r1*sin(theta);
    vec2 offset_pos = dst_pos-cur_pos;
    
    offset_pos.x *= frameResolution.x;
    offset_pos.y *= frameResolution.y;
    offset_pos *= mix(1.0, 3.0, u_isMiddleLowDevice);
    
    vec4 out_uv = vec4(offset_pos, 0.0, alpha);

    return out_uv;
}

void main()
{
    gl_FragColor = RenderUV(gl_PointCoord);
    // gl_FragColor = vec4(1.0);
}

