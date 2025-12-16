//
//  TuringPatterns.metal
//  ShaderTest
//
//  Created by Porter Glines on 12/1/25.
//

#include <metal_stdlib>
using namespace metal;

float2 random_turing(float2 st) {
    st = float2( dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123);
}

float gradient_noise_turing(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float2 u = f*f*(3.0-2.0*f);
    
    return mix( mix( dot( random_turing(i + float2(0.0, 0.0)), f - float2(0.0, 0.0) ),
                     dot( random_turing(i + float2(1.0, 0.0)), f - float2(1.0, 0.0) ), u.x),
                mix( dot( random_turing(i + float2(0.0, 1.0)), f - float2(0.0, 1.0) ),
                     dot( random_turing(i + float2(1.0, 1.0)), f - float2(1.0, 1.0) ), u.x), u.y);
}

// Mark: Initialization

struct InitUniforms {
    float4 rect; // x, y, width, height
};

[[kernel]]
void init_simulation(texture2d<half, access::write> outTexture [[texture(0)]],
                     constant InitUniforms &uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    float2 uv = float2(gid) / float2(outTexture.get_width(), outTexture.get_height());
    float4 r = uniforms.rect;
    
    half chemA = 1.0;
    half chemB = 0.0;
    float threshold = 0.50;
    float scale = 20.0;
    
    if (uv.x >= r.x && uv.x <= (r.x + r.z) &&
        uv.y >= r.y && uv.y <= (r.y + r.w) &&
        gradient_noise_turing(uv * scale) * 0.5 + 0.5 > threshold) {
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

struct SimUniforms {
    half feed;
    half kill;
    half feed2;
    half kill2;
    half threshold;
};

[[kernel]]
void reaction_diffusion(texture2d<half, access::read> inTexture [[texture(0)]],
                        texture2d<half, access::write> outTexture [[texture(1)]],
                        constant SimUniforms &simUniforms [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]]) {
    half2 uv = half2(gid) / half2(outTexture.get_width(), outTexture.get_height());
    
    half dt = 0.5;
    half da = 1.0, db = 0.5;
    
    half threshold = smoothstep(half(simUniforms.threshold-0.05),
                                half(simUniforms.threshold+0.5),
                                half(1.0 - uv.y));
    half feed = mix(simUniforms.feed, simUniforms.feed2, threshold);
    half kill = mix(simUniforms.kill, simUniforms.kill2, threshold);

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
