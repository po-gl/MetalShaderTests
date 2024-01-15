//
//  ContentView.swift
//  ShaderTest
//
//  Created by Porter Glines on 1/2/24.
//

import SwiftUI

struct Test : Identifiable {
    var view: AnyView
    var title: String
    var id = UUID()

    static func == (lhs: Test, rhs: Test) -> Bool {
        lhs.id == rhs.id
    }
}

struct ContentView: View {
    let tests: [Test] = [
        Test(view: AnyView(PickGradientTest()), title: "Pick Gradient Tests"),
        Test(view: AnyView(BlurTest()), title: "Blur Tests"),
        Test(view: AnyView(NoiseTest()), title: "Noise Tests"),
        Test(view: AnyView(PixellateTest()), title: "Pixellate Tests"),
        Test(view: AnyView(WaveyTest()), title: "Wavey Tests"),
        Test(view: AnyView(ColorsTest()), title: "Colors Tests")
    ]
    let bookOfShaders: [Test] = [
        Test(view: AnyView(BoSShapingFunctions()), title: "Shaping Functions"),
        Test(view: AnyView(BoSColors()), title: "Colors")
    ]
    var body: some View {
        NavigationStack {
            List {
                Section("Tests") {
                    ForEach(tests) { test in
                        NavigationLink {
                            test.view
                                .navigationTitle(test.title)
                        } label: {
                            Text(test.title)
                        }
                    }
                }
                Section("Book of Shaders") {
                    ForEach(bookOfShaders) { test in
                        NavigationLink {
                            test.view
                                .navigationTitle(test.title)
                        } label: {
                            Text(test.title)
                        }
                    }
                }
            }
            .navigationTitle("Shader Tests")
        }
    }
}

#Preview {
    ContentView()
}
