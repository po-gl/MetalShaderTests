//
//  PickGradient.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

#include <metal_stdlib>

using namespace metal;

extern float random(float2 st);

[[ stitchable ]] half4 pickGradient(float2 pos, half4 existingColor, float4 boundingRect,
                                    float zoom, half4 newColor, float top, float bottom) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
//    uv.x += t * 0.05;
    
    uv.x *= boundingRect.z / boundingRect.w;
    uv *= zoom;
    uv.x -= zoom/2;
    
    float2 ipos = floor(uv);
    
    top = 1.0 - top;
    bottom = 1.0 - bottom;
    
    float r = random(ipos);
    r = step(smoothstep(top, bottom, 1.0 - ipos.y / zoom), r);
    half3 color = half3(r);
    
    return half4(color, existingColor.a);
}

[[ stitchable ]] half4 pickGradientWithGradient(float2 pos, half4 existingColor, float4 boundingRect, half4 glow) {
    float zoom = 60.0;
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    uv.x *= boundingRect.z / boundingRect.w;
    uv *= zoom;
    
    float2 ipos = floor(uv);
    
    float r = random(ipos);
    r = step(smoothstep(0.1, 0.8, 1.0 - ipos.y / zoom), r);
    half4 color = half4(0.0, 0.0, 0.0, 1.0 - r);
    
    // Mix in gradient
    glow.a = 1.0 - ((uv.y / zoom) + 0.2);
    color = mix(color, glow, 1.0 - color.a);
    
    // Compositor expects premultiplied colors for alpha blending
    color = half4(color.rgb * color.a, color.a);
    
    return color;
}
