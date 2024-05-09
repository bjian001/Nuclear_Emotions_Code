precision highp float;
attribute vec3 attPosition;
attribute vec2 attUV;
uniform vec4 u_ScreenParams;
varying highp vec2 blurCoordinates[9];
 
void main()
{
    gl_Position = vec4(attPosition, 1.0);
    float texelWidthOffset = 8. * (u_ScreenParams.z - 1.0);
    float texelHeightOffset = 8. * (u_ScreenParams.w - 1.0);
    blurCoordinates[0] = attUV + vec2(-texelWidthOffset, -texelHeightOffset);
    blurCoordinates[1] = attUV + vec2(0., -texelHeightOffset);
    blurCoordinates[2] = attUV + vec2(texelWidthOffset, -texelHeightOffset);
    blurCoordinates[3] = attUV + vec2(-texelWidthOffset, 0.);
    blurCoordinates[4] = attUV;
    blurCoordinates[5] = attUV + vec2(texelWidthOffset, 0.);
    blurCoordinates[6] = attUV + vec2(-texelWidthOffset, texelHeightOffset);
    blurCoordinates[7] = attUV + vec2(0., texelHeightOffset);
    blurCoordinates[8] = attUV + vec2(texelWidthOffset, texelHeightOffset);
}
