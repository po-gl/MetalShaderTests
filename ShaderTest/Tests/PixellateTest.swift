//
//  PixellateTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

import SwiftUI

struct PixellateTest: View {
    @State var strength = 2.0

    var body: some View {
        VStack {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 100))
                .layerEffect(ShaderLibrary.pixellate(.float(strength)), maxSampleOffset: .zero)
            GroupBox {
                HStack {
                    Text("Pixellate strength: ")
                    Spacer()
                    Text(String(format: "%.3f", strength))
                        .monospacedDigit()
                }
                Slider(value: $strength, in: 0.0...12.0)
            }
            .frame(width: 300)
        }
    }
}

#Preview {
    PixellateTest()
}
