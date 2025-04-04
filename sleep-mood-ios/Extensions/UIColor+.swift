//
//  UIColor+.swift
//  sleep-mood-ios
//
//  Created by luelh on 4/4/25.
//

import UIKit

extension UIColor {
    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

    static func decode(from data: Data) -> UIColor? {
        try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
}
