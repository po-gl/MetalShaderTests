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

float2x2 rotate(float angle) {
    return float2x2(cos(angle), -sin(angle),
                    sin(angle), cos(angle));
}

float halftoneGrid(float2 st, float gridSize = 0.05, float angle = 0.0) {
    st.x -= (1.0 - gridSize)/2;
    float2 rot_st = rotate(angle) * st;
    
    float2 gridPos = floor(rot_st / gridSize);
    float2 center = gridPos * gridSize + gridSize/2;
    float radius = gridSize/2 + gridSize/4 - (st.y * st.y * gridSize * 1.0);
    
    float dist = distance(rot_st, center);
    if (dist < radius) {
        return 1.0;
    }
    return 0.0;
}

[[ stitchable ]] half4 halftone(float2 pos, half4 existingColor, float4 boundingRect, float t, float size) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    uv.x *= boundingRect.z / boundingRect.w;
    
    half4 color = 0.0;
    float colorSize = size * 1.0;
    
    half4 cyan = half4(0.53, 0.81, 0.92, 0.0);
    cyan.a = halftoneGrid(float2(uv.x-0.009, uv.y-0.000), colorSize, 0.26);
    color = mix(color, cyan, 1.0 - color.a);
    
    half4 magenta = half4(0.77, 0.25, 0.40, 0.0);
    magenta.a = halftoneGrid(float2(uv.x+0.008, uv.y-0.005), colorSize, -0.08);
    color = mix(color, magenta, 1.0 - color.a);
    
    half4 green = half4(0.35, 0.63, 0.55, 0.0);
    green.a = halftoneGrid(float2(uv.x-0.009, uv.y-0.000), colorSize, 0.06);
    color = mix(color, green, 1.0 - color.a);
    
    half4 yellow = half4(0.89, 0.85, 0.41, 0.0);
    yellow.a = halftoneGrid(float2(uv.x+0.012, uv.y+0.006), colorSize, -0.01) * 0.8;
    color = mix(color, yellow, 1.0 - color.a);
    
    half4 black = 0.0;
    black.a = halftoneGrid(float2(uv.x, uv.y), size*0.9, 0.0);
    color = mix(black, color, 1.0 - black.a);
    
    // Compositor expects premultiplied colors for alpha blending
    return half4(color.rgb * color.a, color.a);
}
