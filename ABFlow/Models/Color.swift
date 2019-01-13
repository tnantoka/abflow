//
//  Color.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/12.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

struct Color {
    static let primary = UIColor(hex: 0x344955)
    static let primaryDark = UIColor(hex: 0x232F34)
    static let primaryLight = UIColor(hex: 0x4A6572)

    static let secondary = UIColor(hex: 0xF9AA33)

    static let text = UIColor(hex: 0x17262A)
    static let textMuted = UIColor(hex: 0x767676)

    static let white = UIColor(hex: 0xFEFEFE)
    static let lightGray = UIColor(hex: 0xF3F5F6)
    static let darkGray = UIColor(hex: 0xEDF0F2)
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(hex: hex, alpha: 1.0)
    }

    convenience init(hex: UInt32, alpha: CGFloat) {
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
