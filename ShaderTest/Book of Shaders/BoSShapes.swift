//
//  BoSShapes.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/15/24.
//

import SwiftUI

struct BoSShapes: View {
    var views : [Test] = [
        Test(view: AnyView(RectShapes()), title: "Rect!"),
        Test(view: AnyView(Mondrian()), title: "Mondrian"),
        Test(view: AnyView(CircleShapes()), title: "Circle!"),
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

struct RectShapes: View {
    @State var width = 0.2;
    @State var smoothness = 0.015;
    @State var offset = CGPoint(x: 0.7, y: 0.7);

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.indigo)
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.rectShape(.boundingRect,
                                                     .float(width),
                                                     .float(smoothness),
                                                     .float2(offset)))
                .allowsHitTesting(false)
                .padding(.bottom)
            
            GroupBox {
                HStack {
                    Text("Size:")
                    Spacer()
                    Text(String(format: "%.3f", width))
                }
                Slider(value: $width, in: 0.0...0.5)
            }
            GroupBox {
                HStack {
                    Text("Smoothness:")
                    Spacer()
                    Text(String(format: "%.3f", smoothness))
                }
                Slider(value: $smoothness, in: 0.0...0.1)
            }
            GroupBox {
                HStack {
                    Text("X offset:")
                    Spacer()
                    Text(String(format: "%.3f", offset.x))
                }
                Slider(value: $offset.x, in: 0.0...1.0)
            }
            GroupBox {
                HStack {
                    Text("Y offset:")
                    Spacer()
                    Text(String(format: "%.3f", offset.y))
                }
                Slider(value: $offset.y, in: 0.0...1.0)
            }
        }
    }
}

struct Mondrian: View {
    let t0 = Date()
    var body: some View {
        TimelineView(.animation) { _ in
            RoundedRectangle(cornerRadius: 8)
                .fill(.pink)
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.mondrian(.boundingRect,
                                                    .float(t0.timeIntervalSinceNow)))
                .allowsHitTesting(false)
        }
    }
}

struct CircleShapes: View {
    let t0 = Date()
    var body: some View {
        TimelineView(.animation) { _ in
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.circleShape(.boundingRect,
                                                       .float(t0.timeIntervalSinceNow)))
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    ScrollView {
        BoSShapes()
    }
}
