precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D lightTex;
uniform float offset_x;
uniform float offset_y;
uniform vec2 scale;
uniform float angle;
uniform float screenW;
uniform float screenH;

varying vec2 texCoordinate;

#define PI 3.1415926

float uvProtect(vec2 uv)
{
    vec2 _uv = step(uv, vec2(1.0)) * step(vec2(0.0), uv);
    return _uv.x * _uv.y;
}

vec2 rotate(vec2 uv, float theta)
{
    uv.y *= screenH / screenW;
    float sint = sin(theta);
    float cost = cos(theta);
    mat2 rot = mat2(
        cost, sint,
        -sint, cost
    );
    uv -= 0.5;
    uv = rot * uv;
    uv += 0.5;
    uv.y *= screenW / screenH;
    return uv;
}

void main() {
    vec4 resultColor = vec4(1.0);

    vec2 distortionCoord_1[3];
    vec2 coord_map;
    
    coord_map.x = texCoordinate.x;
    coord_map.y = texCoordinate.y;
    vec3 refraction_1_x = vec3( 1.0-offset_x*(1.0-coord_map.x), 1.0, 1.0+offset_x*(1.0-coord_map.x));
    vec3 refraction_1_y = vec3( 1.0-offset_y*(1.0-coord_map.y), 1.0, 1.0+offset_y*(1.0-coord_map.y));
    
    distortionCoord_1[0][0] = refraction_1_x[0]*coord_map.x;
    distortionCoord_1[0][1] = refraction_1_y[0]*coord_map.y;
    distortionCoord_1[1][0] = refraction_1_x[1]*coord_map.x;
    distortionCoord_1[1][1] = refraction_1_y[1]*coord_map.y;
    distortionCoord_1[2][0] = refraction_1_x[2]*coord_map.x;
    distortionCoord_1[2][1] = refraction_1_y[2]*coord_map.y;
    vec4 color_b = texture2D(inputImageTexture,distortionCoord_1[0]);
    resultColor.b = color_b.b;
    vec4 color_g = texture2D(inputImageTexture,distortionCoord_1[1]);
    resultColor.g = color_g.g;
    vec4 color_r = texture2D(inputImageTexture,distortionCoord_1[2]);
    resultColor.r = color_r.r;
    resultColor.a = (color_b.a+color_g.a+color_r.a)*0.333333;
    resultColor.rgb = clamp(resultColor.rgb, vec3(0.0), vec3(resultColor.a));

    resultColor.rgb = clamp(resultColor.rgb, 0.0, resultColor.a);

    vec2 uv1 = texCoordinate;
    uv1 = rotate(uv1, angle * PI / 180.0);
    uv1 = (uv1 - .5) / scale + .5;
    vec4 lightColor = texture2D(lightTex, uv1) * uvProtect(uv1);
    resultColor.rgb = mix(resultColor.rgb, clamp(lightColor.rgb / lightColor.a, 0., 1.), lightColor.a);
    resultColor.a = max(resultColor.a, lightColor.a);
    gl_FragColor = resultColor;
    // gl_FragColor = clamp(gl_FragColor, 0.0, gl_FragColor.a);
}