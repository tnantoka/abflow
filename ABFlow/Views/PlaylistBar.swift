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
    var labelTimer: Timer?

    lazy var trackLabel: UILabel = {
        let trackLabel = Util.createLabel()
        return trackLabel
    }()

    lazy var playlistLabel: UILabel = {
        let playlistLabel = Util.createLabel()
        playlistLabel.isHidden = true
        return playlistLabel
    }()

    lazy var durationLabel: UILabel = {
        let durationLabel = Util.createLabel()
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
        return durationLabel
    }()

    lazy var labelStack: UIStackView = {
        let labelStack = UIStackView(arrangedSubviews: [
            trackLabel,
            playlistLabel,
            durationLabel
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
        let playButton = Util.createButton(iconCode: "play.arrow")
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        return playButton
    }()

    lazy var pauseButton: UIButton = {
        let pauseButton = Util.createButton(iconCode: "pause")
        pauseButton.addTarget(self, action: #selector(pauseButtonDidTap), for: .touchUpInside)
        return pauseButton
    }()

    lazy var controlStack: UIStackView = {
        let controlStack = UIStackView(arrangedSubviews: [
            playButton,
            pauseButton
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
        labelTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.trackLabel.isHidden = !self.trackLabel.isHidden
            self.playlistLabel.isHidden = !self.playlistLabel.isHidden
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
        if BackgroundPlayer.shared.playlist != nil {
            onTapLabel()
        }
    }

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            controlStack.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            controlStack.leadingAnchor.constraint(equalTo: labelStack.trailingAnchor, constant: 8.0),
            controlStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            controlStack.widthAnchor.constraint(equalToConstant: 44.0),
            controlStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
        ])
    }

    func updateControls() {
        durationLabel.text = BackgroundPlayer.shared.currentTimeString
        trackLabel.text = BackgroundPlayer.shared.currentTrackTitle
        playlistLabel.text = BackgroundPlayer.shared.playlist?.name

        if BackgroundPlayer.shared.isPlaying {
            playButton.isHidden = true
            pauseButton.isHidden = false
        } else {
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
}
