//
//  ColorsTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/13/24.
//

import SwiftUI

struct ColorsTest: View {
    let t0 = Date()
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 50.0)
                .frame(width: 300, height: 400)
                .visualEffect { content, geometry in
                    content
                        .colorEffect(ShaderLibrary.colors(.float2(geometry.size)))
                }
            
            TimelineView(.animation) { _ in
                Text("Wow colors")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(30)
                    .visualEffect { content, geometry in
                        content
                            .distortionEffect(ShaderLibrary.wave(
                                .float(t0.timeIntervalSinceNow),
                                .float2(geometry.size),
                                .float(0.2),
                                .float(2.0),
                                .float(10.0)
                            ), maxSampleOffset: .zero)
                    }
            }
        }
    }
}

#Preview {
    ColorsTest()
}
