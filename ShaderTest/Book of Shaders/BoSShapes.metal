//
//  BoSShapes.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/15/24.
//

#include <metal_stdlib>
using namespace metal;


half4 sampleSquare(float2 uv, half4 color, float width,
                 float2 offset, float smoothness = 0.0,
                 bool outline = false, float outlineWidth = 0.02,
                 half4 outlineColor = half4(0.0, 0.0, 0.0, 1.0)) {
    width = 0.5 - width;
    uv -= offset - 0.5;
    // bottom - left
    float2 bl = smoothstep(float2(width), float2(width + smoothness), uv);
    float pct = bl.x * bl.y;
    // top - right
    float2 tr = smoothstep(float2(width), float2(width + smoothness), 1.0-uv);
    pct *= tr.x * tr.y;
    color.a = pct;

    if (outline) {
        float2 bl = step(width-outlineWidth, uv);
        float pct = bl.x * bl.y;
        float2 tr = step(width-outlineWidth, 1.0-uv);
        pct *= tr.x * tr.y;
        outlineColor.a = pct;
        
        color = mix(outlineColor, color, color.a);
    }
    return color;
}

half4 sampleRect(float2 uv, half4 color, float2 size,
                 float2 offset, float smoothness = 0.0,
                 bool outline = false, float outlineWidth = 0.02,
                 half4 outlineColor = half4(0.0, 0.0, 0.0, 1.0)) {
    size = 0.5 - size;
    uv -= offset - 0.5;
    // bottom - left
    float b = smoothstep(size.y, size.y + smoothness, uv.y);
    float l = smoothstep(size.x, size.x + smoothness, uv.x);
    float pct = b * l;
    // top - right
    float t = smoothstep(size.y, size.y + smoothness, 1.0-uv.y);
    float r = smoothstep(size.x, size.x + smoothness, 1.0-uv.x);
    pct *= t * r;
    color.a = pct;

    if (outline) {
        b = step(size.y-outlineWidth, uv.y);
        l = step(size.x-outlineWidth, uv.x);
        pct = b * l;
        t = step(size.y-outlineWidth, 1.0-uv.y);
        r = step(size.x-outlineWidth, 1.0-uv.x);
        pct *= t * r;
        outlineColor.a = pct;
        color = mix(outlineColor, color, color.a);
    }
    return color;
}

[[ stitchable ]] half4 rectShape(float2 pos, half4 existingColor, float4 boundingRect,
                                 float width, float smoothness, float2 offset) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    half4 color = half4(0.578, 0.906, 0.703, 1.0);
    
    half4 rect = sampleSquare(uv, color, width, offset, smoothness);
    half3 colorMix = mix(existingColor.rgb, rect.rgb, rect.a);
    
    return half4(colorMix, existingColor.a);
}

[[ stitchable ]] half4 circleShape(float2 pos, half4 existingColor, float4 boundingRect, float t) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    half4 color = half4(uv.x + cos(t), uv.y + sin(t), 0.703, 1.0);
    float2 middle = float2(0.5);
    float radius = 0.3;
    
    float pct = distance(uv, middle) + (1.0 - radius);
    pct = 1.0 - pct;
    pct = smoothstep(0.0, 0.04, pct);
    color.a = pct;
    
    half3 colorMix = mix(existingColor.rgb, color.rgb, color.a);
    
    return half4(colorMix, existingColor.a);
}

[[ stitchable ]] half4 mondrian(float2 pos, half4 existingColor, float4 boundingRect, float t) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;

    // Red area
    half4 red = half4(0.56, 0.12, 0.12, 1.0);
    red += 0.1*sin(t);
    half4 rect = sampleRect(uv, red, float2(0.06, 0.16), float2(0.0, 0.98), 0.0, true);
    half3 colorMix = mix(existingColor.rgb, rect.rgb, rect.a);

    rect = sampleRect(uv, red, float2(0.06, 0.16), float2(0.14, 0.98), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, red, float2(0.06, 0.08), float2(0.0, 0.72), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, red, float2(0.06, 0.08), float2(0.14, 0.72), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    // Yellow area
    half4 yellow = half4(0.75, 0.60, 0.16, 1.0);
    yellow += 0.2*sin(t+M_PI_H);
    rect = sampleRect(uv, yellow, float2(0.06, 0.16), float2(1.04, 0.98), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    rect = sampleRect(uv, yellow, float2(0.06, 0.08), float2(1.04, 0.72), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    // Blue area
    half4 blue = half4(0.0, 0.31, 0.49, 1.0);
    blue += 0.2*sin(t+M_PI_H);
    rect = sampleRect(uv, blue, float2(0.08, 0.06), float2(0.88, 0.02), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    rect = sampleRect(uv, blue, float2(0.06, 0.06), float2(1.04, 0.02), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    // Off-white areas
    half4 white = half4(0.72, 0.70, 0.67, 1.0);
    rect = sampleRect(uv, white, float2(0.28, 0.16), float2(0.5, 0.98), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    rect = sampleRect(uv, white, float2(0.28, 0.08), float2(0.5, 0.72), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, white, float2(0.08, 0.16), float2(0.88, 0.98), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    rect = sampleRect(uv, white, float2(0.08, 0.08), float2(0.88, 0.72), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, white, float2(0.20, 0.32), float2(0.0, 0.3), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, white, float2(0.28, 0.26), float2(0.50, 0.36), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, white, float2(0.08, 0.26), float2(0.88, 0.36), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    rect = sampleRect(uv, white, float2(0.06, 0.26), float2(1.04, 0.36), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    rect = sampleRect(uv, white, float2(0.28, 0.06), float2(0.50, 0.02), 0.0, true);
    colorMix = mix(colorMix, rect.rgb, rect.a);
    
    return half4(colorMix, existingColor.a);
}
