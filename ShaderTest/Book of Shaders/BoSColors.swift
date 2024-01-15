//
//  BoSColors.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

import SwiftUI

struct BoSColors: View {
    var views : [Test] = [
        Test(view: AnyView(MixingColors()), title: "Mix"),
        Test(view: AnyView(MixingColorChannels()), title: "Channels"),
        Test(view: AnyView(Spectrum()), title: "🌈"),
        Test(view: AnyView(PolarSpectrum()), title: "Polar"),
        Test(view: AnyView(ExpandSpectrum()), title: "Expand"),
    ]

    @State var selectedViewIdx = 4
    var selectedViewIdxBinding: Binding<Int> {
        Binding(get: { selectedViewIdx },
                set: { val in withAnimation { selectedViewIdx = val }})
    }

    var body: some View {
        VStack {
            Picker("Pick a Colors Shader", selection: selectedViewIdxBinding) {
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

struct MixingColors: View {
    let t0 = Date()
    var body: some View {
        TimelineView(.animation) { _ in
            Rectangle()
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.mixColors(.float(t0.timeIntervalSinceNow),
                                                     .color(.orange),
                                                     .color(.blue)))
                .allowsHitTesting(false)
        }
    }
}

struct MixingColorChannels: View {
    @State var i1 = 1.0
    @State var i2 = 1.0
    @State var i3 = 1.0

    let t0 = Date()
    var body: some View {
        ScrollView {
            TimelineView(.animation) { _ in
                Rectangle()
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.mixColorChannels(.boundingRect,
                                                                .float(i1),
                                                                .float(i2),
                                                                .float(i3)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("R influence")
                    Spacer()
                    Text(String(format: "%.3f", i1))
                }
                Slider(value: $i1, in: 0.0...2.0)
            }
            GroupBox {
                HStack {
                    Text("G influence")
                    Spacer()
                    Text(String(format: "%.3f", i2))
                }
                Slider(value: $i2, in: 0.0...2.0)
            }
            GroupBox {
                HStack {
                    Text("B influence")
                    Spacer()
                    Text(String(format: "%.3f", i3))
                }
                Slider(value: $i3, in: 0.0...2.0)
            }
        }
    }
}

struct Spectrum: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.spectrum(.boundingRect))
                .allowsHitTesting(false)
            
            Text("HSB where hue is x-axis\nand brightness is y-axis")
                .fontDesign(.rounded)
                .padding()
        }
    }
}

struct PolarSpectrum: View {
    let t0 = Date()
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.polarSpectrum(.boundingRect,
                                                             .float(t0.timeIntervalSinceNow)))
                    .allowsHitTesting(false)
            }
            
            Text("The same HSB spectrum but in polar coordinates. It was originally designed to be represented this way!")
                .fontDesign(.rounded)
                .padding()
        }
    }
}

struct ExpandSpectrum: View {
    @State var control = 0.3;
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.expandSpectrum(.boundingRect,
                                                          .float(control)))
                .allowsHitTesting(false)
        }
        .padding(.bottom)
        
        GroupBox {
            HStack {
                Text("Hue control:")
                Spacer()
                Text(String(format: "%.3f", control))
            }
            Slider(value: $control, in: 0.0...1.0)
        }
    }
}

#Preview {
    BoSColors()
}
