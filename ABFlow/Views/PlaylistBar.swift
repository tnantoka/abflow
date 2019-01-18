//
//  PlaylistBar.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/14.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

class PlaylistBar: UIView {

    var onTapLabel: () -> Void = {}
    var playerTimer: Timer?

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = Color.text
        durationLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)

        return titleLabel
    }()

    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.textColor = Color.text
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)

        return durationLabel
    }()

    lazy var labelStack: UIStackView = {
        let labelStack = UIStackView(arrangedSubviews: [
            titleLabel,
            durationLabel,
        ])

        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.distribution = .fillEqually

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelStackDidTap))
        labelStack.addGestureRecognizer(tapRecognizer)

        addSubview(labelStack)

        return labelStack
    }()

    lazy var playButton: UIButton = {
        let playButton = UIButton(type: .system)

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        playButton.tintColor = Color.text

        let playImage = UIImage(from: .materialIcon, code: "play.arrow", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        playButton.setImage(playImage, for: .normal)

        return playButton
    }()

    lazy var pauseButton: UIButton = {
        let pauseButton = UIButton(type: .system)

        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.addTarget(self, action: #selector(pauseButtonDidTap), for: .touchUpInside)
        pauseButton.tintColor = Color.text
        pauseButton.isHidden = true

        let pauseImage = UIImage(from: .materialIcon, code: "pause", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        pauseButton.setImage(pauseImage, for: .normal)

        return pauseButton
    }()

    lazy var controlStack: UIStackView = {
        let controlStack = UIStackView(arrangedSubviews: [
            playButton,
            pauseButton,
        ])

        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.axis = .horizontal
        controlStack.distribution = .fillEqually

        addSubview(controlStack)

        return controlStack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Color.secondary

        buildLayout()

        playerTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateControls()
        }
        updateControls()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func playButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.play()
    }

    @objc func pauseButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.pause()
    }

    @objc func labelStackDidTap(sender: Any) {
        if let _ = BackgroundPlayer.shared.playlist {
            onTapLabel()
        }
    }

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            controlStack.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            controlStack.leadingAnchor.constraint(equalTo: labelStack.trailingAnchor, constant: 8.0),
            controlStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            controlStack.widthAnchor.constraint(equalToConstant: 44.0),
            controlStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
        ])
    }

    func updateControls() {
        durationLabel.text = BackgroundPlayer.shared.currentTimeString
        titleLabel.text = "\(BackgroundPlayer.shared.currentTrackTitle ?? "") - \(BackgroundPlayer.shared.playlist?.name ?? "")"

        if BackgroundPlayer.shared.isPlaying {
            playButton.isHidden = true
            pauseButton.isHidden = false
        } else {
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
}
