//
//  BoSShapingFunctions.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

#include <metal_stdlib>
using namespace metal;

float simplePlot(float2 st) {
    return smoothstep(0.02, 0.0, abs(st.y - st.x));
}

float plot(float2 st, float pct) {
    return smoothstep(pct-0.02, pct, st.y) - smoothstep(pct, pct+0.02, st.y);
}

[[ stitchable ]] half4 simpleShapingFunction(float2 pos, half4 existingColor, float4 boundingRect) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y; // flip y axis
    
    half y = uv.x;
    
    half3 color = half3(y);
    
    float pct = simplePlot(uv);
    color = (1.0-pct) * color + pct * half3(0.0, 1.0, 0.0);
    
    return half4(color, 1.0);
}

[[ stitchable ]] half4 expShapingFunction(float2 pos, half4 existingColor, float4 boundingRect, float exp) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y; // flip y axis
    
    float y = pow(uv.x, exp);
    
    half3 color = half3(y);
    
    float pct = plot(uv, y);
    color = (1.0-pct) * color + pct * half3(0.0, 1.0, 0.0);

    return half4(color, 1.0);
}

[[ stitchable ]] half4 impulseShapingFunction(float2 pos, half4 existingColor, float4 boundingRect, float k) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y; // flip y axis
    
    float h = k * uv.x;
    float y = h * exp(1.0 - h);
    
    half3 color = half3(y);
    
    float pct = plot(uv, y);
    color = (1.0-pct) * color + pct * half3(0.0, 1.0, 0.0);

    return half4(color, 1.0);
}
