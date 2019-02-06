//
//  ItemCell.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/13.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    var isPlaying: Bool = false {
        didSet {
            borderView.isHidden = !isPlaying
        }
    }

    lazy var borderView: UIView = {
        let borderView = UIView()

        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = Color.secondary

        contentView.addSubview(borderView)

        return borderView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = Color.white
        layer.borderColor = Color.darkGray.cgColor
        layer.borderWidth = 4.0

        textLabel?.textColor = Color.text
        detailTextLabel?.textColor = Color.textMuted

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Color.lightGray

        buildLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        borderView.backgroundColor = Color.secondary
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        borderView.backgroundColor = Color.secondary
    }

    // MARK: - Utils

    func buildLayout() {
        guard let textLabel = textLabel else { return }
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            borderView.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor,
                                                 constant: -4.5 * UIScreen.main.scale),
            borderView.widthAnchor.constraint(equalToConstant: 2.0),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0)
        ])
    }
}
