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

    static func createBarButtonItem(iconCode: String, target: Any?, action: Selector?) -> UIBarButtonItem {
        let image = UIImage(from: .materialIcon, code: iconCode, textColor: .black,
                               backgroundColor: .clear, size: CGSize(width: 28.0, height: 28.0))
        let item = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        return item
    }

    static func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = Color.darkGray
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = 60.0

        return tableView
    }

    static func createSlider() -> UISlider {
        let slider = UISlider(frame: .zero)

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = false
        slider.minimumValue = 0.0
        slider.tintColor = Color.text
        slider.thumbTintColor = Color.primary

        return slider
    }

    static func createStackView(_ arrangedSubviews: [UIView], vertical: Bool = true) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = vertical ? .vertical : .horizontal
        stack.distribution = .fillEqually

        return stack
    }
}
