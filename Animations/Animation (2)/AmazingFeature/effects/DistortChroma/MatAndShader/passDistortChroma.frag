precision highp float;
varying highp vec2 uv0;
uniform sampler2D gradientTex;
uniform sampler2D u_albedo;
uniform float sizeIntensity;
uniform float u_angle;
uniform float width;
uniform float height;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

float decode(vec4 g)
{
    float ret = 0.0;
    ret = g.x + g.y / 255.0 + g.z / (65025.0) + g.w / (16581375.0);
    return ret;
}

vec2 flip_uv(vec2 uv) 
{
    return abs(mod(uv + 1., 2.) - 1.0);
}

#define PI 3.1415926

vec2 rot(float angle, vec2 uv)
{
    float theta = angle * PI / 180.;
    mat2 r = mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
    float ratio = float(width) / float(height);
    if (ratio < 1.) uv.x *= ratio;
    else uv.y /= ratio;
    // uv.x *= 9. / 16.;
    vec2 uv1 = uv * r;
    if (ratio < 1.) uv.x /= ratio;
    else uv.y *= ratio;
    return uv1;
}

void main()
{
    vec2 uvt = sizeIntensity / vec2(width, height);
    if (abs(sizeIntensity) < .01) {
        gl_FragColor = texture2D(u_albedo, uv0);
        return;
    }
    float rescale = min(width, height) / 720.;
    // uvt = rot(u_angle, uvt);
    uvt *= rescale;
    float gradientSourceX1 = decode(texture2D(gradientTex, uv0 + rot(u_angle, vec2(uvt.x, 0.0))));
    float gradientSourceX2 = decode(texture2D(gradientTex, uv0 - rot(u_angle, vec2(uvt.x, 0.0))));
    float gradientSourceY1 = decode(texture2D(gradientTex, uv0 + rot(u_angle, vec2(0.0, uvt.y))));
    float gradientSourceY2 = decode(texture2D(gradientTex, uv0 - rot(u_angle, vec2(0.0, uvt.y))));

    float dx = (gradientSourceX1 - gradientSourceX2) * 1.;
    float dy = (gradientSourceY1 - gradientSourceY2) * 1.;
    vec2 d = vec2(dx, dy);

    vec2 uv1 = uv0;
    float intensity = 3.;
    uv1.x += d.x * intensity;
    uv1.y += d.y * intensity;

    vec2 diff = uv1 - uv0;
    float steps = 10.;
    vec2 delta = diff / steps;
    vec4 colors[23];
    float f0 = .6;

    float weight[23];
    float sigma = 4.;
    weight[1] = normpdf(1. / 20. * 15.0, sigma);
    weight[2] = normpdf(2. / 20. * 15.0, sigma);
    weight[3] = normpdf(3. / 20. * 15.0, sigma);
    weight[4] = normpdf(4. / 20. * 15.0, sigma);
    weight[5] = normpdf(5. / 20. * 15.0, sigma);
    weight[6] = normpdf(6. / 20. * 15.0, sigma);
    weight[7] = normpdf(7. / 20. * 15.0, sigma);
    weight[8] = normpdf(8. / 20. * 15.0, sigma);
    weight[9] = normpdf(9. / 20. * 15.0, sigma);
    weight[10] = normpdf(10. / 20. * 15.0, sigma);
    weight[11] = normpdf(11. / 20. * 15.0, sigma);
    weight[12] = normpdf(12. / 20. * 15.0, sigma);
    weight[13] = normpdf(13. / 20. * 15.0, sigma);
    weight[14] = normpdf(14. / 20. * 15.0, sigma);
    weight[15] = normpdf(15. / 20. * 15.0, sigma);
    weight[16] = normpdf(16. / 20. * 15.0, sigma);
    weight[17] = normpdf(17. / 20. * 15.0, sigma);
    weight[18] = normpdf(18. / 20. * 15.0, sigma);
    weight[19] = normpdf(19. / 20. * 15.0, sigma);
    weight[20] = normpdf(20. / 20. * 15.0, sigma);
    weight[21] = normpdf(21. / 20. * 15.0, sigma);
    weight[22] = normpdf(22. / 20. * 15.0, sigma);

    colors[0] = texture2D(u_albedo, (uv0 + delta * (f0 + 0. * .1 * .35)));
    colors[1] = texture2D(u_albedo, (uv0 + delta * (f0 + 1. * .1 * .35))) * weight[1];
    colors[2] = texture2D(u_albedo, (uv0 + delta * (f0 + 2. * .1 * .35))) * weight[2];
    colors[3] = texture2D(u_albedo, (uv0 + delta * (f0 + 3. * .1 * .35))) * weight[3];
    colors[4] = texture2D(u_albedo, (uv0 + delta * (f0 + 4. * .1 * .35))) * weight[4];
    colors[5] = texture2D(u_albedo, (uv0 + delta * (f0 + 5. * .1 * .35))) * weight[5];
    colors[6] = texture2D(u_albedo, (uv0 + delta * (f0 + 6. * .1 * .35))) * weight[6];
    colors[7] = texture2D(u_albedo, (uv0 + delta * (f0 + 7. * .1 * .35))) * weight[7];
    colors[8] = texture2D(u_albedo, (uv0 + delta * (f0 + 8. * .1 * .35))) * weight[8];
    colors[9] = texture2D(u_albedo, (uv0 + delta * (f0 + 9. * .1 * .35))) * weight[9];
    colors[10] = texture2D(u_albedo, (uv0 + delta * (f0 + 10. * .1 * .35))) * weight[10];
    colors[11] = texture2D(u_albedo, (uv0 + delta * (f0 + 11. * .1 * .35))) * weight[11];
    colors[12] = texture2D(u_albedo, (uv0 + delta * (f0 + 12. * .1 * .35))) * weight[12];
    colors[13] = texture2D(u_albedo, (uv0 + delta * (f0 + 13. * .1 * .35))) * weight[13];
    colors[14] = texture2D(u_albedo, (uv0 + delta * (f0 + 14. * .1 * .35))) * weight[14];
    colors[15] = texture2D(u_albedo, (uv0 + delta * (f0 + 15. * .1 * .35))) * weight[15];
    colors[16] = texture2D(u_albedo, (uv0 + delta * (f0 + 16. * .1 * .35))) * weight[16];
    colors[17] = texture2D(u_albedo, (uv0 + delta * (f0 + 17. * .1 * .35))) * weight[17];
    colors[18] = texture2D(u_albedo, (uv0 + delta * (f0 + 18. * .1 * .35))) * weight[18];
    colors[19] = texture2D(u_albedo, (uv0 + delta * (f0 + 19. * .1 * .35))) * weight[19];
    colors[20] = texture2D(u_albedo, (uv0 + delta * (f0 + 20. * .1 * .35))) * weight[20];
    colors[21] = texture2D(u_albedo, (uv0 + delta * (f0 + 21. * .1 * .35))) * weight[21];
    colors[22] = texture2D(u_albedo, (uv0 + delta * (f0 + 22. * .1 * .35))) * weight[22];
    
    float sumWeightB = 0.;
    float sumWeightG = 0.;
    sumWeightB = weight[10] + weight[11] + weight[12] + weight[13]
    + weight[14] + weight[15] + weight[16] + weight[17]
    + weight[18] + weight[19] + weight[20] + weight[21];
    sumWeightG = weight[1] + weight[2] + weight[3] + weight[4]
    + weight[5] + weight[6] + weight[7] + weight[8]
    + weight[9] + weight[10] + weight[11] + weight[12];
    vec4 resultColor = colors[0];
    float aAvg = colors[0].a;
    float aMax = colors[0].a;

    // aAvg /= 22.;
    aAvg = (colors[0] + colors[1] + colors[2] + colors[3]
    + colors[4] + colors[5] + colors[6] + colors[7]
    + colors[8] + colors[9] + colors[10] + colors[11]
    + colors[12] + colors[13] + colors[14] + colors[15]
    + colors[16] + colors[17] + colors[18] + colors[19]
    + colors[20] + colors[21]).a;
    aAvg /= (1. + weight[1] + weight[2] + weight[3]
    + weight[4] + weight[5] + weight[6] + weight[7]
    + weight[8] + weight[9] + weight[10] + weight[11]
    + weight[12] + weight[13] + weight[14] + weight[15]
    + weight[16] + weight[17] + weight[18] + weight[19]
    + weight[20] + weight[21]);
    resultColor.b = (colors[10] + colors[11] + colors[12] + colors[13]
    + colors[14] + colors[15] + colors[16] + colors[17]
    + colors[18] + colors[19] + colors[20] + colors[21]).b / (sumWeightB);
    resultColor.g = (colors[1] + colors[2] + colors[3] + colors[4]
    + colors[5] + colors[6] + colors[7] + colors[8]
    + colors[9] + colors[10] + colors[11] + colors[12]).g / (sumWeightG);
    resultColor.a = aAvg;
    gl_FragColor = resultColor;
}
