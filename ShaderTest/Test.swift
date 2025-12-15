//
//  Test.swift
//  ShaderTest
//
//  Created by Porter Glines on 11/15/25.
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
