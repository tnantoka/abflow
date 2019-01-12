//
//  Color.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/12.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

struct Color {
    static let white = UIColor(hex: 0xFEFEFE)
    static let lightGray = UIColor(hex: 0xEDF0F2)
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
