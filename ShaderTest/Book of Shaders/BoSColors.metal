//
//  BoSColors.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

#include <metal_stdlib>
using namespace metal;

inline float colorsPlot(float2 st, float pct) {
    return smoothstep(pct-0.01, pct, st.y) - smoothstep(pct, pct+0.01, st.y);
}

[[ stitchable ]] half4 mixColors(float2 pos, half4 existingColor,
                                 float t, half4 c1, half4 c2) {
    float pct = abs(sin(t));
    return mix(c1, c2, pct);
}

[[ stitchable ]] half4 mixColorChannels(float2 pos, half4 existingColor,
                                        float4 boundingRect,
                                        float i1, float i2, float i3) {
    half4 c1 = half4(0.149, 0.141, 0.912, 1.0);
    half4 c2 = half4(1.000, 0.833, 0.224, 1.0);
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    half3 pct = half3(uv.x);
    
    pct.r = smoothstep(0.0, i1, uv.x);
    pct.g = sin(uv.x*M_PI_H) * i2;
    pct.b = pow(uv.x, 0.5) * i3;
    
    half3 color = mix(c1.rgb, c2.rgb, pct);

    // Plot transition for each channel
    color = mix(color, half3(1.0, 0.0, 0.0), colorsPlot(uv, pct.r));
    color = mix(color, half3(0.0, 1.0, 0.0), colorsPlot(uv, pct.g));
    color = mix(color, half3(0.0, 0.0, 1.0), colorsPlot(uv, pct.b));
    
    return half4(color, 1.0);
}

inline half3 rgb2hsb(half3 c){
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 p = mix(half4(c.bg, K.wz),
                  half4(c.gb, K.xy),
                  step(c.b, c.g));
    half4 q = mix(half4(p.xyw, c.r),
                  half4(c.r, p.yzx),
                  step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                 d / (q.x + e),
                 q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
inline half3 hsb2rgb(half3 c){
    half3 rgb = clamp(abs(fmod(c.x*6.0+half3(0.0,4.0,2.0),
                               6.0)-3.0)-1.0,
                      0.0,
                      1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(half3(1.0), rgb, c.y);
}

[[ stitchable ]] half4 spectrum(float2 pos, half4 existingColor, float4 boundingRect) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    half3 color = half3(0.0);
    
    // HSB (hue, saturation, brightness)
    // so hue for x-axis and brightness for y-axis
    color = hsb2rgb(half3(uv.x, 1.0, uv.y));
    return half4(color, existingColor.a);
}

[[ stitchable ]] half4 polarSpectrum(float2 pos, half4 existingColor, float4 boundingRect, float t) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    half3 color = half3(0.0);
    
    t *= 0.1;
    
    // Using polar coordinates!
    float2 toCenter = float2(0.5) - uv;
    float angle = atan2(toCenter.y, toCenter.x) + t;
    float radius = length(toCenter) * 2.0;
    
    color = hsb2rgb(half3((angle/(2.0*M_PI_H))+0.5 - t, radius, 1.0));
    
    return half4(color, existingColor.a);
}

float pcurve(float x, float a, float b) {
    float k = pow(a+b, a+b) / (pow(a, a) * pow(b, b));
    return k * pow(x, a) * pow(1.0-x, b);
}

[[ stitchable ]] half4 expandSpectrum(float2 pos, half4 existingColor, float4 boundingRect,
                                      float control) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    half3 color = half3(0.0);
    
    // Using polar coordinates!
    float2 toCenter = float2(0.5) - uv;
    float angle = atan2(toCenter.y, toCenter.x);
    float radius = length(toCenter) * 2.0;
    
    float hue = fract((angle/(2.0*M_PI_H))+0.5);
    hue = mix(smoothstep(0.0, 1.0, hue), hue, 0.3);
    
    color = hsb2rgb(half3(hue + control, radius, 1.0));
    
    return half4(color, existingColor.a);
}
