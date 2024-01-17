//
//  BoSNoise.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/15/24.
//

import SwiftUI

struct BoSNoise: View {
    var views : [Test] = [
        Test(view: AnyView(NoiseGraph()), title: "Graph"),
        Test(view: AnyView(Noise()), title: "Noise"),
        Test(view: AnyView(PerlinNoise()), title: "Perlin"),
        Test(view: AnyView(StripeNoise()), title: "Stripes"),
        Test(view: AnyView(PaintNoise()), title: "Paint"),
    ]

    @State var selectedViewIdx = 4
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

struct NoiseGraph: View {
    let t0 = Date()
    @State var smoothness = true;
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                Rectangle()
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.noiseGraph(.boundingRect,
                                                          .float(t0.timeIntervalSinceNow),
                                                          .float(smoothness ? 1.0 : 0.0)))
                    .border(Color(UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Toggle(isOn: $smoothness, label: {
                        Text("Smoothness")
                    })
                }
            }
        }
    }
}

struct Noise: View {
    let t0 = Date()
    @State var zoom = 30.0;
    @State var color = true;
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.basicNoise(.boundingRect,
                                                          .float(t0.timeIntervalSinceNow),
                                                          .float(zoom),
                                                          .float(color ? 1.0 : 0.0)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("Zoom")
                    Spacer()
                    Text(String(format: "%.3f", zoom))
                        .monospacedDigit()
                }
                Slider(value: $zoom, in: 1.0...50.0)
            }
            GroupBox {
                HStack {
                    Toggle(isOn: $color, label: {
                        Text("Color")
                    })
                }
            }
        }
    }
}

struct PerlinNoise: View {
    let t0 = Date()
    @State var zoom = 30.0;
    @State var color = true;
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.perlinNoise(.boundingRect,
                                                          .float(t0.timeIntervalSinceNow),
                                                          .float(zoom),
                                                          .float(color ? 1.0 : 0.0)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("Zoom")
                    Spacer()
                    Text(String(format: "%.3f", zoom))
                        .monospacedDigit()
                }
                Slider(value: $zoom, in: 1.0...50.0)
            }
            GroupBox {
                HStack {
                    Toggle(isOn: $color, label: {
                        Text("Color")
                    })
                }
            }
        }
    }
}

struct StripeNoise: View {
    let t0 = Date()
    @State var zoom = 0.24;
    @State var color = true;
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.stripeNoise(.boundingRect,
                                                           .float(t0.timeIntervalSinceNow),
                                                           .float(zoom),
                                                           .float(color ? 1.0 : 0.0)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("Zoom")
                    Spacer()
                    Text(String(format: "%.3f", zoom))
                        .monospacedDigit()
                }
                Slider(value: $zoom, in: 0.1...1.0)
            }
            GroupBox {
                HStack {
                    Toggle(isOn: $color, label: {
                        Text("Color")
                    })
                }
            }
        }
    }
}

struct PaintNoise: View {
    let t0 = Date()
    @State var zoom = 1.0;
    @State var color = true;
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.paintNoise(.boundingRect,
                                                           .float(t0.timeIntervalSinceNow),
                                                           .float(zoom),
                                                           .float(color ? 1.0 : 0.0)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("Zoom")
                    Spacer()
                    Text(String(format: "%.3f", zoom))
                        .monospacedDigit()
                }
                Slider(value: $zoom, in: 0.1...3.0)
            }
            GroupBox {
                HStack {
                    Toggle(isOn: $color, label: {
                        Text("Color")
                    })
                }
            }
        }
    }
}


#Preview {
    BoSNoise()
}
