//
//  BoSNoise.metal
//  ShaderTest
//
//  Created by Porter Glines on 1/15/24.
//

#include <metal_stdlib>
using namespace metal;

extern float rand(float x);
extern float random(float2 st);
extern float plot(float2 st, float pct);
extern half3 palette(float t);

float grid(float2 st) {
    float2 fpos = fract(st);
    return step(fpos.x, 0.98) * step(fpos.y, 0.98);
}

[[ stitchable ]] half4 noiseGraph(float2 pos, half4 existingColor, float4 boundingRect, float t, float smooth) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    uv -= 0.5;
    uv *= 8.0;
    
    uv.x -= t;
    
    half3 color = half3(0.0, 0.0, 1.0);
    float pct = grid(uv);
    color = (1.0 - pct) * color + pct * half3(1.0);
    
    float i = floor(uv.x);
    float f = fract(uv.x);
    float y = 0.0;
    if (smooth == 1.0) {
        y = mix(rand(i), rand(i + 1.0), smoothstep(0.0, 1.0, f)) * 2.0;
    } else {
        y = mix(rand(i), rand(i + 1.0), f) * 2.0;
    }
    
    pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * half3(0.0);
    
    return half4(color, existingColor.a);
}

float noise(float2 st) {
    float2 ipos = floor(st);
    float2 fpos = fract(st);
    
    float a = random(ipos);
    float b = random(ipos + float2(1.0, 0.0));
    float c = random(ipos + float2(0.0, 1.0));
    float d = random(ipos + float2(1.0, 1.0));
    
    // Cubic Hermine Curve
    float2 u = fpos*fpos*(3.0-2.0*fpos);
//     u = smoothstep(0.0, 1.0, fpos); // same as smoothstep
    
    // Mix 4 corner percentages
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float2 random2(float2 st) {
    st = float2( dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123);
}

float gradientNoise(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float2 u = f*f*(3.0-2.0*f);
    
    return mix( mix( dot( random2(i + float2(0.0, 0.0)), f - float2(0.0, 0.0) ),
                     dot( random2(i + float2(1.0, 0.0)), f - float2(1.0, 0.0) ), u.x),
                mix( dot( random2(i + float2(0.0, 1.0)), f - float2(0.0, 1.0) ),
                     dot( random2(i + float2(1.0, 1.0)), f - float2(1.0, 1.0) ), u.x), u.y);
}

[[ stitchable ]] half4 basicNoise(float2 pos, half4 existingColor, float4 boundingRect, float t, float zoom, float isColor) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    uv *= zoom;
    uv -= zoom/2;
    uv.x -= t;
    
    float n = noise(uv);
    
    half3 color = 0.0;
    if (isColor == 1.0) {
        n = smoothstep(0.3, 1.0, n);
        color = palette(n);
    } else {
        color = half3(n);
    }
    
    return half4(color, existingColor.a);
}

// Demonstrates the difference between Value Noise (1 float random)
// and Gradient Noise (float2 random)
[[ stitchable ]] half4 perlinNoise(float2 pos, half4 existingColor, float4 boundingRect, float t, float zoom, float isColor) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    uv *= zoom;
    uv -= zoom/2;
    uv.x -= t;
    
    float n = gradientNoise(uv) * 0.5 + 0.5;
    
    half3 color = 0.0;
    if (isColor == 1.0) {
        n = smoothstep(0.1, 0.9, n);
        color = palette(n);
    } else {
        color = half3(n);
    }
    
    return half4(color, existingColor.a);
}

matrix<float, 2> rotate2d(float angle) {
    return matrix<float, 2>(cos(angle), -sin(angle),
                            sin(angle), cos(angle));
}

float lines(float2 pos, float b) {
    float scale = 10.0;
    pos *= scale;
    return smoothstep(0.0, 0.5+b*0.5, abs((sin(pos.x*M_PI_F)+b*2.0))*0.5);
}

// Relies on rotating the space
[[ stitchable ]] half4 stripeNoise(float2 pos, half4 existingColor, float4 boundingRect, float t, float zoom, float isColor) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    pos = uv.yx * float2(10.0, 3.0) * zoom - zoom/2.0;
    
    pos.y += 2.0;
    
    float f = abs(1.0 - sin(t*0.1)) * 5.0;
    pos += gradientNoise(pos) * f;
    pos = rotate2d( gradientNoise(pos) ) * pos;
    
    float pattern = lines(pos, 0.5);
    half3 color = 0.0;
    
    if (isColor == 1.0) {
        color = palette(pattern);
    } else {
        color = half3(pattern);
    }
    
    return half4(color, existingColor.a);
}


[[ stitchable ]] half4 paintNoise(float2 pos, half4 existingColor, float4 boundingRect, float t, float zoom, float isColor) {
    float2 uv = pos / boundingRect.zw;
    uv.y = 1.0 - uv.y;
    
    uv.x *= boundingRect.z / boundingRect.w;
    uv *= zoom;
    uv -= zoom/2.0;
    
    uv.x += 2.0;
    
    float f = abs(1.0 - sin(t*0.1)) * 5.0;
    uv += gradientNoise(uv * 2.0) * f;
    
    float n = smoothstep(0.18, 0.2, gradientNoise(uv));
    n += smoothstep(0.15, 0.3, gradientNoise(uv*10.0));
    n -= smoothstep(0.35, 0.38, gradientNoise(uv*10.0));
    
    half3 color = 0.0;
    if (isColor == 1.0) {
        color = palette(n);
    } else {
        color = 1.0 - n;
    }
    
    return half4(color, existingColor.a);
}
