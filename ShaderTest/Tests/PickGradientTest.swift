//
//  PickGradientTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

import SwiftUI

struct PickGradientTest: View {
    @State var size = 10.0
    var body: some View {
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 200)
                .colorEffect(ShaderLibrary.pickGradient(.boundingRect, .float(size), .color(.mint)))
            
            GroupBox {
                HStack {
                    Text("Size:")
                    Spacer()
                    Text(String(format: "%.3f", size))
                        .monospacedDigit()
                }
                Slider(value: $size, in: 0.001...50)
            }
        }
        .padding()
    }
}

#Preview {
    PickGradientTest()
}
