precision highp float;

uniform sampler2D u_videoTex;

varying vec2 uv;

void main ()
{
    //if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >=0.0 && uv.y <= 1.0)
    //{
        gl_FragColor = texture2D(u_videoTex, uv);
    //}
    //else
    //{
    //    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    //}
}

