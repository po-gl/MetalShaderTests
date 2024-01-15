//
//  Colors.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 colors(float2 position, half4 currentColor, float2 size) {
    float2 normalizedPosition = position / size;
    return half4(normalizedPosition.x, normalizedPosition.y, normalizedPosition.x, currentColor.a);
}
