//
//  WaveyTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

import SwiftUI

struct WaveyTest: View {
    @State var speed = 0.5
    @State var strength = 8.0
    @State var frequency = 10.0
    @State var t0 = Date()

    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                // Compute elapsed on the main actor to avoid capturing @State in a @Sendable closure
                let elapsed = -t0.timeIntervalSinceNow
                let s = speed
                let k = strength
                let f = frequency
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 100))
                    .visualEffect { content, geometry in
                        content
                            .distortionEffect(ShaderLibrary.wave(
                                .float(elapsed),
                                .float2(geometry.size),
                                .float(s),
                                .float(k),
                                .float(f)
                            ), maxSampleOffset: .zero)
                    }
            }
            GroupBox {
                HStack {
                    Text("Speed: ")
                    Spacer()
                    Text(String(format: "%.3f", speed))
                        .monospacedDigit()
                }
                Slider(value: $speed, in: 0.0...3.0)
                HStack {
                    Text("Strength: ")
                    Spacer()
                    Text(String(format: "%.3f", strength))
                        .monospacedDigit()
                }
                Slider(value: $strength, in: 0.0...20.0)
                HStack {
                    Text("Frequency: ")
                    Spacer()
                    Text(String(format: "%.3f", frequency))
                        .monospacedDigit()
                }
                Slider(value: $frequency, in: 0.0...50.0)
            }
            .frame(width: 300)
        }
    }
}

#Preview {
    WaveyTest()
}
