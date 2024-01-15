//
//  PickGradient.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

#include <metal_stdlib>

using namespace metal;

[[ stitchable ]] half4 pickGradient(float2 pos, half4 color, float4 boundingRect, float size, half4 newColor) {
    float2 uv = pos / boundingRect.zw;
//    uint2 posInChecks = uint2(uv.x / size, uv.y / size);
    uint2 posInChecks = uint2(pos.x / size, pos.y / size);
    bool isColor = (posInChecks.x ^ posInChecks.y) & 1;
    newColor.a *= uv.y;
    return isColor ? newColor : half4(0.0, 0.0, 0.0, 0.0);
}
