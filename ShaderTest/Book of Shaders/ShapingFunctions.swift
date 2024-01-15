//
//  ShapingFunctions.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/14/24.
//
// Resources:
// http://iquilezles.org/articles/functions/ for more functions like impulse
// http://www.flong.com/archive/texts/code/shapers_poly/ polynomial shaping functions
// many other functions like exponential and bezier on both sites

import SwiftUI

struct ShapingFunctions: View {
    var views : [Test] = [
        Test(view: AnyView(SimpleFunction()), title: "Simple"),
        Test(view: AnyView(ExpFunction()), title: "Exp"),
        Test(view: AnyView(ImpulseFunction()), title: "Impulse"),
    ]

    @State var selectedViewIdx = 2
    var selectedViewIdxBinding: Binding<Int> {
        Binding(get: { selectedViewIdx },
                set: { val in withAnimation { selectedViewIdx = val }})
    }

    var body: some View {
        VStack {
            Picker("Pick the Shaping Function Shader", selection: selectedViewIdxBinding) {
                ForEach(Array(views.enumerated()), id: \.offset) { i, view in
                    Text(view.title).tag(i)
                }
            }
            .pickerStyle(.segmented)
            
            let selected = views[selectedViewIdx]
            VStack {
                Text(selected.title)
                    .font(.title)
                    .fontDesign(.serif)
                selected.view
                    .transition(.opacity)
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}

struct SimpleFunction: View {
    var body: some View {
        Rectangle()
            .frame(width: 300, height: 300)
            .colorEffect(ShaderLibrary.simpleShapingFunction(.boundingRect))
            .allowsHitTesting(false)
    }
}

struct ExpFunction: View {
    @State var exp = 2.0
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.expShapingFunction(.boundingRect, .float(exp)))
                .allowsHitTesting(false)
            
            GroupBox {
                HStack {
                    Text("Exponential")
                    Spacer()
                    Text(String(format: "%.3f", exp))
                }
                Slider(value: $exp, in: 0.0...20.0)
            }
        }
    }
}

struct ImpulseFunction: View {
    @State var impulse = 10.0
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 300, height: 300)
                .colorEffect(ShaderLibrary.impulseShapingFunction(.boundingRect, .float(impulse)))
                .allowsHitTesting(false)
            
            GroupBox {
                HStack {
                    Text("Impulse Factor")
                    Spacer()
                    Text(String(format: "%.3f", impulse))
                }
                Slider(value: $impulse, in: 0.0...20.0)
            }
        }
    }
}

#Preview {
    ShapingFunctions()
}
