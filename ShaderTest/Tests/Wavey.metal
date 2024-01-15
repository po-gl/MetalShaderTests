//
//  Wavey.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] float2 wave(float2 position, float time, float2 size,
                             float speed, float stength, float frequency) {
    float2 normalizedPosition = position / size;
    float moveAmount = time * speed;
    
    position.x += sin((normalizedPosition.x + moveAmount) * frequency) * stength;
    position.y += cos((normalizedPosition.y + moveAmount) * frequency) * stength;
    return position;
}
