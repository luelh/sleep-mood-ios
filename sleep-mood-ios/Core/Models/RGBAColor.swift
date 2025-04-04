//
//  RGBAColor.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import SwiftUI

struct RGBAColor: Equatable, Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
}

extension RGBAColor {
    var color: Color {
        Color(red: red, green: green, blue: blue).opacity(alpha)
    }

    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
}
