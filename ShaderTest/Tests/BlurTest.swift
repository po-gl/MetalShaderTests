//
//  BlurTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/12/24.
//

import SwiftUI

struct BlurTest: View {
    let rainbow: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    ForEach(rainbow, id: \.self) { color in
                        Rectangle()
                            .fill(color)
                            .frame(width: 20, height: 100)
                    }
                }
                .padding(.horizontal)
                .background(.white)
                .drawingGroup()
                .layerEffect(ShaderLibrary.blurTest(.boundingRect), maxSampleOffset: .zero)
                Text("Blurrs")
            }
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 300, height: 2)
        }
    }
}

#Preview {
    BlurTest()
}
