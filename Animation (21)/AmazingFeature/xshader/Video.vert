precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

uniform vec2 u_pos;
uniform float u_scale;
uniform float u_angle;
uniform vec4 u_size;
uniform float u_flipX;
uniform float u_flipY;

varying vec2 uv;

void main ()
{
    gl_Position = vec4(attPosition, 1.0);
    uv = attUV * 2. - 1.;
    // if (u_size.z < u_size.w)
    // {
    //     uv.y = uv.y * u_size.z / u_size.w;
    // }
    // else
    // {
    //     uv.x = uv.x * u_size.w / u_size.z;
    // }
    if (u_flipX > 0.5)
    {
        uv.x = -uv.x;
    }
    if (u_flipY > 0.5)
    {
        uv.y = -uv.y;
    }
    uv = uv * .5 + .5;
}
