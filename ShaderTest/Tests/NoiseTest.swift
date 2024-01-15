//
//  NoiseTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

import SwiftUI

struct NoiseTest: View {
    let rainbow: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    let t0 = Date()

    var body: some View {
        TimelineView(.animation) { _ in
            HStack(spacing: 0) {
                ForEach(rainbow, id: \.self) { color in
                    Rectangle()
                        .fill(color)
                        .frame(width: 20, height: 100)
                }
            }
            .colorEffect(ShaderLibrary.noise(.float(t0.timeIntervalSinceNow)))
        }
    }
}

#Preview {
    NoiseTest()
}
