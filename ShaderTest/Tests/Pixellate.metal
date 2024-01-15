//
//  Pixellate.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]] half4 pixellate(float2 position, SwiftUI::Layer layer, float stength) {
    float min_stength = max(stength, 0.0001);
    float coord_x = min_stength * round(position.x / min_stength);
    float coord_y = min_stength * round(position.y / min_stength);
    return layer.sample(float2(coord_x, coord_y));
}
