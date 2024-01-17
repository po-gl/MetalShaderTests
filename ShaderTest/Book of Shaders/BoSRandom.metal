//
//  BoSRandom.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/15/24.
//

#include <metal_stdlib>
using namespace metal;

float rand(float x) {
    return fract(sin(x)*100000.0);
}

float random(float2 st) {
    return fract(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

[[ stitchable ]] half4 randomChaos(float2 pos, half4 existingColor, float4 boundingRect) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    uv *= 10;
    
    float2 ipos = floor(uv);
    float2 fpos = fract(uv);
    
//    half3 color = half3(rand(ipos.x * ipos.y));
    half3 color = half3(random(ipos));
    
    color += half3(fpos.x, fpos.y, 0.0) * 0.2;
    
    return half4(color, existingColor.a);
}

float2 truchetPattern(float2 st, float index) {
    index = fract((index-0.5)*2.0);
    if (index > 0.75) {
        st = float2(1.0) - st;
    } else if (index > 0.5) {
        st = float2(1.0-st.x, st.y);
    } else if (index > 0.25) {
        st = 1.0 - float2(1.0-st.x, st.y);
    }
    return st;
}

[[ stitchable ]]  half4 randomTruchet(float2 pos, half4 existingColor, float4 boundingRect, float t, float seed) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    t *= 0.4;
    
    uv *= 15;
    
    float2 ipos = floor(uv);
    float2 fpos = fract(uv);
    
    float2 tile = truchetPattern(fpos, random(ipos + seed));
    
    half3 color = 0.0;
    
    color = smoothstep(tile.x-0.1, tile.x, tile.y) - smoothstep(tile.x, tile.x+0.8, tile.y);
    color = mix(color, half3(sin(t) + 0.4, cos(t) + 0.4, sin(t + M_PI_H/2) + 0.4), color.r);
    
    return half4(color, existingColor.a);
}
