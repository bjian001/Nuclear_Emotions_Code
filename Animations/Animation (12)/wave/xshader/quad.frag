precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;
uniform float iTime;
uniform float scope;
uniform float speed;
uniform float rate;
uniform int twistX;

// #define PI = 3.14159;
// 
void main()
{
 float s = 1.0 - scope * 2.0;

  float ox = uv0.x;
  float oy = uv0.y;

    ox = sin(mod(uv0.y * rate * 2.0, 2.0) * 3.14159) * scope;
    ox = (uv0.x) + ox * sin(iTime);
    if (ox < 0.0){
      ox = -ox;
    }else if(ox > 1.0){
      ox = 2.0 - ox;

  }
//  if(twistY == 1){
//    oy = sin(mod(coordnate.x * rate * 2.0 + time * speed, 2.0) * PI) * scope;
//    oy = coordnate.y * s + scope + oy;
//  }

  vec2 uv = vec2(ox, oy);

  vec4 color = texture2D(u_albedo, uv);

  gl_FragColor = color;
}
