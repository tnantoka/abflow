//
//  Util.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/12.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

class Util {
    static func formatDuration(_ duration: Double?) -> String {
        guard let duration = duration else { return "" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: duration) ?? ""
    }

    static func createView(white: Bool = true) -> UIView {
        let view = UIView(frame: .zero)

        view.translatesAutoresizingMaskIntoConstraints = false
        if white {
            view.backgroundColor = Color.white
        }

        return view
    }

    static func createLabel(center: Bool = false) -> UILabel {
        let label = UILabel(frame: .zero)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Color.text
        if center {
            label.textAlignment = .center
        }

        return label
    }

    static func createButton(title: String? = nil, iconCode: String? = nil, red: Bool = false) -> UIButton {
        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.tintColor = red ? Color.red : Color.text

        if let title = title {
            button.setTitle(title, for: .normal)
        }
        if let iconCode = iconCode {
            let image = UIImage(from: .materialIcon, code: iconCode, textColor: .black,
                                    backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
            button.setImage(image, for: .normal)
        }

        return button
    }

    static func createBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem()
    }
}
