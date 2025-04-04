//
//  Color+.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import SwiftUI

extension Color {
    var toData: Data? {
        UIColor(self).encode()
    }

    init?(data: Data) {
        guard let uiColor = UIColor.decode(from: data) else { return nil }
        self = Color(uiColor)
    }
}


