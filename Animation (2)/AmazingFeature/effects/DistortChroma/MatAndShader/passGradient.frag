precision highp float;
varying highp vec2 uv0;
uniform sampler2D u_albedo;

float rgb2grey(vec3 rgbColor){
    return (rgbColor.r*0.299 + rgbColor.g*0.587 + rgbColor.b*0.114);
}

vec4 encode(float grey)
{
    vec4 res = vec4(0.0, 0.0, 0.0, 0.0);
    grey *= 255.0;
    res.x = floor(grey) / 255.0;

    grey = fract(grey);
    grey *= 255.0;
    res.y = floor(grey) / 255.0;

    grey = fract(grey);
    grey *= 255.0;
    res.z = floor(grey) / 255.0;

    // grey = fract(grey);
    // grey *= 255.0;
    grey = fract(grey);
    res.w = grey;
    return res;
}

void main()
{
    vec4 inputColor = texture2D(u_albedo, uv0);
    float grey = rgb2grey(inputColor.rgb);
    vec4 resultColor = encode(grey);
    gl_FragColor = resultColor;
}
