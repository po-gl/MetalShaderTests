//
//  PickGradientTest.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//

import SwiftUI

struct PickGradientTest: View {
    var views : [Test] = [
        Test(view: AnyView(BasicPickGradient()), title: "Basic"),
        Test(view: AnyView(ColorEffectPickGradient()), title: "Recreated"),
        Test(view: AnyView(HalfTone()), title: "Halftone"),
    ]

    @State var selectedViewIdx = 2
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
    
struct BasicPickGradient: View {
    let t0 = Date()
    @State var zoom = 60.0
    @State var top = 0.8
    @State var bottom = 0.2;
    
    func animateZoom(delta: CGFloat) {
        let tick = delta > 0 ? 1.0 : -1.0
        Task { @MainActor in
            for _ in 0..<abs(Int(delta)) {
                try? await Task.sleep(for: .milliseconds(16))
                zoom += tick;
            }
        }
    }
    func animateTop(delta: CGFloat, steps: Int) {
        let tick = delta / CGFloat(steps)
        
        Task { @MainActor in
            for _ in 0..<steps {
                try? await Task.sleep(for: .milliseconds(16))
                top += tick;
            }
        }
    }
    func animateBottom(delta: CGFloat, steps: Int) {
        let tick = delta / CGFloat(steps)
        
        Task { @MainActor in
            for _ in 0..<steps {
                try? await Task.sleep(for: .milliseconds(16))
                bottom += tick;
            }
        }
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 200)
                .colorEffect(ShaderLibrary.pickGradient(.boundingRect,
                                                        .float(zoom),
                                                        .color(.mint),
                                                        .float(top),
                                                        .float(bottom)))
                .border(.blue)
                .allowsHitTesting(false)
                .padding()
            
            GroupBox {
                HStack {
                    Text("Animate")
                    Spacer()
                    Button("Press") {
                        // I like the animation of bottom the most
//                        let zoomDelta = 50.0
//                        let topDelta = 0.2
                        let bottomDelta = 0.3
//                        animateZoom(delta: zoomDelta)
//                        animateTop(delta: topDelta, steps: Int(zoomDelta))
                        animateBottom(delta: bottomDelta, steps: 50)
                        Task {
                            try? await Task.sleep(for: .seconds(2))
//                            animateZoom(delta: -zoomDelta)
//                            animateTop(delta: -topDelta, steps: Int(zoomDelta))
                            animateBottom(delta: -bottomDelta, steps: 50)
                        }
                        
                        // Animations through Transactions appears to not work with metal shaders
//                        withAnimation {
//                            zoom += zoomDelta
//                        }
//                        Task { @MainActor in
//                            try? await Task.sleep(for: .seconds(3.0))
//                            withAnimation {
//                                zoom -= zoomDelta
//                            }
//                        }
                    }
                }
            }
            
            GroupBox {
                HStack {
                    Text("Zoom:")
                    Spacer()
                    Text(String(format: "%.3f", zoom))
                        .monospacedDigit()
                }
                Slider(value: $zoom, in: 0.001...150)
            }
            
            GroupBox {
                HStack {
                    Text("Top:")
                    Spacer()
                    Text(String(format: "%.3f", top))
                        .monospacedDigit()
                }
                Slider(value: $top, in: 0.01...1.0)
            }
            
            GroupBox {
                HStack {
                    Text("Bottom:")
                    Spacer()
                    Text(String(format: "%.3f", bottom))
                        .monospacedDigit()
                }
                Slider(value: $bottom, in: 0.01...1.0)
            }
        }
        .padding(.horizontal)
    }
}

struct ColorEffectPickGradient: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? .white : .white)
                    .frame(width: 350, height: 350)
                    .border(.blue)
                HStack {
                    Rectangle()
                        .frame(width: 40, height: 40)
                    Rectangle()
                        .fill(.indigo)
                        .frame(width: 40, height: 40)
                }
                .offset(y: -150)
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 300, height: 300)
                    .colorEffect(ShaderLibrary.pickGradientWithGradient(.boundingRect,
                                                                        .color(.pink)))
                    .allowsHitTesting(false)
                    .border(.green)
            }
            .padding(.bottom)
            
            Text("PRE-MULTIPLIED ALPHA BLENDING.\nIt isn't well documented as a requirement by Apple, but the compositing layer expects pre-multiplied alpha blended colors.\nOtherwise two rectangles have their colors shifted. This appears to be a Metal bug where alpha values are not properly respected in .colorEffect(:).")
                .fontDesign(.rounded)
                .padding()
        }
    }
}

struct HalfTone: View {
    let t0 = Date()
    @State var size = 0.05;
    var body: some View {
        VStack {
            TimelineView(.animation) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 300)
                    .colorEffect(ShaderLibrary.halftone(.boundingRect,
                                                        .float(t0.timeIntervalSinceNow),
                                                        .float(size)))
                    .allowsHitTesting(false)
            }
            
            GroupBox {
                HStack {
                    Text("Size:")
                    Spacer()
                    Text(String(format: "%.3f", size))
                }
                Slider(value: $size, in: 0.0001...0.2)
            }
        }
    }
}

#Preview {
    ScrollView {
        PickGradientTest()
    }
    .background(.gray)
}
