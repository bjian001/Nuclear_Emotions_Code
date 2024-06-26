
precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform sampler2D maskTexture;
uniform lowp float uniAlpha;
void main() 
{
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

     highp float blueColor = textureColor.b * 63.0;

     highp vec2 quad1;
     quad1.y = floor(floor(blueColor) / 8.0);
     quad1.x = floor(blueColor) - (quad1.y * 8.0);

     highp vec2 quad2;
     quad2.y = floor(ceil(blueColor) /8.0);
     quad2.x = ceil(blueColor) - (quad2.y * 8.0);

     highp vec2 texPos1;
     texPos1.x = (quad1.x * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * textureColor.r);
     texPos1.y = (quad1.y * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * textureColor.g);

     //texPos1.x = 1.0 - texPos1.x;
     // texPos1.y = 1.0 - texPos1.y;

     highp vec2 texPos2;
     texPos2.x = (quad2.x * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * textureColor.r);
     texPos2.y = (quad2.y * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * textureColor.g);

     //texPos2.x = 1.0 - texPos2.x;
     // texPos2.y = 1.0 - texPos2.y;


     lowp vec4 newColor1 = texture2D(inputImageTexture2, texPos1);
     lowp vec4 newColor2 = texture2D(inputImageTexture2, texPos2);

     lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
     lowp vec4 filterCol = mix(textureColor, vec4(newColor.rgb, textureColor.w), uniAlpha);
     highp vec2 maskCoord = vec2(textureCoordinate.x, 1.0 - textureCoordinate.y);
     float mask = texture2D(maskTexture, maskCoord).a;

     gl_FragColor = mix(textureColor,filterCol,mask);
}




