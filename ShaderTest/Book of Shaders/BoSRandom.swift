//
//  BoSRandom.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/15/24.
//

import SwiftUI

struct BoSRandom: View {
    var views : [Test] = [
        Test(view: AnyView(Random()), title: "Chaos"),
        Test(view: AnyView(TruchetPattern()), title: "Truchet"),
    ]

    @State var selectedViewIdx = 1
    var selectedViewIdxBinding: Binding<Int> {
        Binding(get: { selectedViewIdx },
                set: { val in withAnimation { selectedViewIdx = val }})
    }

    var body: some View {
        VStack {
            Picker("Pick a Shapes Shader", selection: selectedViewIdxBinding) {
                ForEach(Array(views.enumerated()), id: \.offset) { i, view in
                    Text(view.title).tag(i)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            let selected = views[selectedViewIdx]
            VStack {
                Text(selected.title)
                    .font(.title)
                    .fontDesign(.serif)
                selected.view
            }
            .id(selectedViewIdx)
            .transition(BlurReplaceTransition(configuration: .downUp))
            Spacer()
        }
        .padding()
    }
}

struct Random: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 300, height: 300)
            .colorEffect(ShaderLibrary.randomChaos(.boundingRect))
            .allowsHitTesting(false)
    }
}

struct TruchetPattern: View {
    let t0 = Date()
    @State var randomValue = Float.random(in: 0.0...1.0);
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.randomTruchet(.boundingRect,
                                                             .float(t0.timeIntervalSinceNow),
                                                             .float(randomValue)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("Seed: \(randomValue)")
                    Spacer()
                    Button("Get new seed") {
                        randomValue = Float.random(in: 0.0...1.0)
                    }
                }
            }
        }
    }
}

#Preview {
    BoSRandom()
}
