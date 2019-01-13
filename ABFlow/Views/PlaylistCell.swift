//
//  PlaylistCell.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/13.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = Color.white
        layer.borderColor = Color.darkGray.cgColor
        layer.borderWidth = 4.0

        textLabel?.textColor = Color.text
        detailTextLabel?.textColor = Color.textMuted

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Color.lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
