//
//  Blur.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/12/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// Code from https://github.com/daprice/Variablur

inline half gaussian(half distance, half sigma) {
    const half gaussianExponent = -(distance * distance) / (2.0h * sigma * sigma);
    return (1.0h / (2.0h * M_PI_H * sigma * sigma)) * exp(gaussianExponent);
}

half4 gaussianBlur1D(float2 position, SwiftUI::Layer layer, half radius, half maxSamples) {
    const half interval = max(1.0h, radius / maxSamples);
    
    const half weight = gaussian(0.0h, radius / 2.0h);
    half4 weightedColorSum = layer.sample(position) * weight;
    half totalWeight = weight;
    
    if(interval <= radius) {
        for (half distance = interval; distance <= radius; distance += interval) {
            const half2 offsetDistance = half2(1, 0) * distance;
            const half weight = gaussian(distance, radius / 2.0h);

            totalWeight += weight * 2.0h;

            weightedColorSum += layer.sample(float2(half2(position) + offsetDistance)) * weight;
            weightedColorSum += layer.sample(float2(half2(position) - offsetDistance)) * weight;
        }
    }
    return weightedColorSum / totalWeight;
}

[[ stitchable ]] half4 blurTest(float2 position, SwiftUI::Layer layer, float4 boundingRect) {
    float2 uv = float2(position.x / boundingRect.z, position.y / boundingRect.w);
    half radius = 20.0 * uv.y;
    half maxSamples = 15.0;

    return gaussianBlur1D(position, layer, radius, maxSamples);
}
