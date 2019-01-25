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

    static func createView(transparent: Bool = false) -> UIView {
        let view = UIView(frame: .zero)

        view.translatesAutoresizingMaskIntoConstraints = false
        if !transparent {
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

}
