precision highp float;
uniform sampler2D u_AlbedoTexture;
uniform sampler2D u_InputTexture;
uniform sampler2D u_colorTexture;
uniform sampler2D u_filterTexture;

uniform vec4 u_Time;
uniform vec4 u_AlbedoColor;
uniform vec2 u_pos;
uniform vec2 u_offset;
uniform float u_color;
uniform float decay;
uniform float density;
uniform float weight;
uniform float u_filterAlpha;
uniform int nsamples;
uniform mat4 u_OrientationMat;

varying vec2 uv0;
vec4 crepuscular_rays(sampler2D u_albedo, vec2 texCoords, vec2 pos) {
  // float decay = 0.92;
  // float density = 0.1;
  // float weight = 0.58767;
  // /// NUM_SAMPLES will describe the rays quality, you can play with
  const int nsamples = 128;

  vec2 tc = texCoords.xy;
  // vec2 deltaTexCoord = u_pos.xy;
  vec4 deltaTexCoord = vec4(tc - vec2(u_pos.x, 1.-u_pos.y), 0.5, 0);
  // deltaTexCoord = u_OrientationMat * deltaTexCoord;
  // deltaTexCoord.xy = (deltaTexCoord.xy / deltaTexCoord.w);
  deltaTexCoord *= (1.0 / float(nsamples) * density);
  float illuminationDecay = 1.0;

  vec4 color = texture2D(u_albedo, tc.xy) * vec4(0.4);

  tc += deltaTexCoord.xy *
        fract(sin(dot(texCoords.xy, vec2(12.9898, 78.233))) * 43758.5453);
  for (int i = 0; i < 128; i++) {
    tc -= deltaTexCoord.xy;
    vec4 sampl = texture2D(u_albedo, tc.xy) * vec4(0.4);

    sampl *= illuminationDecay * weight;
    color += sampl;
    illuminationDecay *= decay;
  }
  // return color;
  return vec4(color.r) * texture2D(u_colorTexture, vec2(u_color, 0.5));
}
vec3 BlendScreen(vec3 base, vec3 blend) {
  return vec3(1.0) - ((vec3(1.0) - base) * (vec3(1.0) - blend));
}
vec3 BlendScreen(vec3 base, vec3 blend, float opacity) {
  return (BlendScreen(base, blend) * opacity + base * (1.0 - opacity));
}
void main() {
  vec2 uv = uv0 - u_offset;
  vec4 inputColor = texture2D(u_InputTexture, uv);
  vec4 resultColor = crepuscular_rays(u_AlbedoTexture, uv, u_pos);
  gl_FragColor = resultColor + inputColor;
  gl_FragColor.a = inputColor.a;
  // gl_FragColor = texture2D(u_AlbedoTexture, uv);
}
