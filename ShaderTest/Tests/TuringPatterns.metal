//
//  TuringPatterns.metal
//  ShaderTest
//
//  Created by Porter Glines on 12/1/25.
//

#include <metal_stdlib>
using namespace metal;

// Mark: Initialization

[[kernel]]
void init_simulation(texture2d<half, access::write> outTexture [[texture(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    half chemA = 1.0;
    half chemB = 0.0;
    half s = 50;
    
    uint2 texCenter = uint2(outTexture.get_width(), outTexture.get_height()) / 2;
    if (gid.x > texCenter.x - s && gid.x < texCenter.x + s &&
        gid.y > texCenter.y - s && gid.y < texCenter.y + s) {
        chemB = 1.0;
    }
    
    outTexture.write(half4(chemA, chemB, 0.0, 1.0), gid);
}

// Mark: Simulation

half2 laplacian(texture2d<half, access::read> tex, uint2 pos) {
    half2 center = tex.read(pos).xy;
    uint2 dx = uint2(1, 0);
    uint2 dy = uint2(0, 1);
    half2 neighbors =
    tex.read(pos - dx).xy +
    tex.read(pos + dx).xy +
    tex.read(pos - dy).xy +
    tex.read(pos + dy).xy;
    
    half2 diagonals =
    tex.read(pos - dx - dy).xy +
    tex.read(pos + dx - dy).xy +
    tex.read(pos - dx + dy).xy +
    tex.read(pos + dx + dy).xy;
    
    return (0.2 * neighbors + 0.05 * diagonals) - center;
}

[[kernel]]
void reaction_diffusion(texture2d<half, access::read> inTexture [[texture(0)]],
                        texture2d<half, access::write> outTexture [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]]) {
    half dt = 0.5;
    half da = 1.0, db = 0.5;
    half feed = 0.055, kill = 0.062;
    
    half2 state = inTexture.read(gid).xy;
    half2 l = laplacian(inTexture, gid);
    half a = state.x, b = state.y;
    half reaction = a * b * b;
    
    half2 diff = dt * half2(da * l.x - reaction + feed * (1.0 - a),
                            db * l.y + reaction - (kill + feed) * b);
    half2 newState = clamp(state + diff, 0.0, 1.0);
    outTexture.write(half4(newState, 0, 0), gid);
}

// Mark: Render Pass

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

[[vertex]]
VertexOut vertex_main(uint vid [[vertex_id]]) {
    // bufferless quad
    float2 grid = float2((vid << 1) & 2, vid & 2);
    VertexOut out;
    out.position = float4(grid * 2.0 - 1.0, 0, 1);
    out.uv = float2(grid.x, 1.0 - grid.y);
    return out;
}

/// cosine based color palette
half3 palette_turing(half t) {
    half3 a = half3(0.5, 0.5, 0.5);
    half3 b = half3(0.5, 0.5, 0.5);
    half3 c = half3(1.0, 1.0, 1.0);
    half3 d = half3(0.263, 0.416, 0.557);
    return a + b*cos(6.28318*(c*t+d));
}

struct Uniforms {
    float time;
};

[[fragment]]
half4 fragment_main(VertexOut in [[stage_in]],
                    texture2d<half> simTexture [[texture(0)]],
                    constant Uniforms &uniforms [[buffer(0)]]) {
    constexpr sampler s (filter::linear, address::clamp_to_edge);
    
    float b = simTexture.sample(s, in.uv).y;
    half t = (b * 2.0) + uniforms.time * 0.01;
    
    half3 color = palette_turing(t);
    return half4(color, 1.0);
}
