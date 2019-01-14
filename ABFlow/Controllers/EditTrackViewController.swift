//
//  EditTrackViewController.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/12.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit
import AVFoundation

class EditTrackViewController: UIViewController {

    let track: Track

    var wholePlayer: AVAudioPlayer?
    var previewPlayer: AVPlayer?
    var durationTimer: Timer?

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)

        return scrollView
    }()

    lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)

        containerView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(containerView)

        return containerView
    }()

    lazy var controlView: UIView = {
        let controlView = UIView(frame: .zero)

        controlView.translatesAutoresizingMaskIntoConstraints = false
        controlView.backgroundColor = Color.white

        containerView.addSubview(controlView)

        return controlView
    }()

    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.backgroundColor = Color.white
        durationLabel.textAlignment = .center
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
        durationLabel.textColor = Color.text
        durationLabel.text = "0:00:00"

        controlView.addSubview(durationLabel)

        return durationLabel
    }()

    lazy var durationSlider: UISlider = {
        let durationSlider = UISlider(frame: .zero)

        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.isContinuous = false
        durationSlider.minimumValue = 0.0
        durationSlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        durationSlider.addTarget(self, action: #selector(durationSliderDidChange), for: .valueChanged)
        durationSlider.tintColor = Color.text
        durationSlider.thumbTintColor = Color.primary

        controlView.addSubview(durationSlider)

        return durationSlider
    }()

    lazy var playButton: UIButton = {
        let playButton = UIButton(type: .system)

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle(NSLocalizedString("Play whole", comment: ""), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        playButton.tintColor = Color.text

        return playButton
    }()

    lazy var pauseButton: UIButton = {
        let pauseButton = UIButton(type: .system)

        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.addTarget(self, action: #selector(pauseButtonDidTap), for: .touchUpInside)
        pauseButton.tintColor = Color.text
        pauseButton.isEnabled = false

        let pauseImage = UIImage(from: .materialIcon, code: "pause", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        pauseButton.setImage(pauseImage, for: .normal)

        return pauseButton
    }()

    lazy var previewButton: UIButton = {
        let previewButton = UIButton(type: .system)

        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.setTitle(NSLocalizedString("Preview", comment: ""), for: .normal)
        previewButton.addTarget(self, action: #selector(previewButtonDidTap), for: .touchUpInside)
        previewButton.tintColor = Color.text

        return previewButton
    }()

    lazy var controlStack: UIStackView = {
        let controlStack = UIStackView(arrangedSubviews: [
            playButton,
            pauseButton,
            previewButton,
        ])

        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.axis = .horizontal
        controlStack.distribution = .fillEqually

        controlView.addSubview(controlStack)

        return controlStack
    }()

    lazy var pointView: UIView = {
        let pointView = UIView(frame: .zero)

        pointView.translatesAutoresizingMaskIntoConstraints = false
        pointView.backgroundColor = Color.white

        containerView.addSubview(pointView)

        return pointView
    }()

    lazy var pointAButton: UIButton = {
        let pointAButton = UIButton(type: .system)

        pointAButton.translatesAutoresizingMaskIntoConstraints = false
        pointAButton.setTitle(NSLocalizedString("Point A", comment: ""), for: .normal)
        pointAButton.addTarget(self, action: #selector(pointAButtonDidTap), for: .touchUpInside)
        pointAButton.setTitleColor(Color.text, for: .normal)
        pointAButton.backgroundColor = Color.secondary
        pointAButton.isEnabled = false
        pointAButton.alpha = 0.7

        return pointAButton
    }()

    lazy var pointALabel: UILabel = {
        let pointALabel = UILabel(frame: .zero)

        pointALabel.translatesAutoresizingMaskIntoConstraints = false
        pointALabel.textColor = Color.text
        pointALabel.textAlignment = .center

        return pointALabel
    }()

    lazy var pointAStack: UIStackView = {
        let pointAStack = UIStackView(arrangedSubviews: [
            pointAButton,
            pointALabel,
        ])

        pointAStack.translatesAutoresizingMaskIntoConstraints = false
        pointAStack.axis = .horizontal
        pointAStack.distribution = .fillEqually

        pointView.addSubview(pointAStack)

        return pointAStack
    }()

    lazy var pointBButton: UIButton = {
        let pointBButton = UIButton(type: .system)

        pointBButton.translatesAutoresizingMaskIntoConstraints = false
        pointBButton.setTitle(NSLocalizedString("Point B", comment: ""), for: .normal)
        pointBButton.addTarget(self, action: #selector(pointBButtonDidTap), for: .touchUpInside)
        pointBButton.setTitleColor(Color.text, for: .normal)
        pointBButton.backgroundColor = Color.secondary
        pointBButton.isEnabled = false
        pointBButton.alpha = 0.7

        return pointBButton
    }()

    lazy var pointBLabel: UILabel = {
        let pointBLabel = UILabel(frame: .zero)

        pointBLabel.translatesAutoresizingMaskIntoConstraints = false
        pointBLabel.textColor = Color.text
        pointBLabel.textAlignment = .center

        return pointBLabel
    }()

    lazy var pointBStack: UIStackView = {
        let pointBStack = UIStackView(arrangedSubviews: [
            pointBButton,
            pointBLabel,
        ])

        pointBStack.translatesAutoresizingMaskIntoConstraints = false
        pointBStack.axis = .horizontal
        pointBStack.distribution = .fillEqually

        pointView.addSubview(pointBStack)

        return pointBStack
    }()

    init(track: Track) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = track.title

        view.backgroundColor = Color.darkGray

        buildLayout()
        updatePointLabels()

        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let wholePlayer = self?.wholePlayer else { return }
            guard let playButton = self?.playButton else { return }
            guard let previewButton = self?.previewButton else { return }

            if playButton.backgroundColor == Color.primary {
                self?.durationLabel.text = Util.formatDuration(wholePlayer.currentTime)
                self?.durationSlider.value = Float(wholePlayer.currentTime)
            } else if previewButton.backgroundColor == Color.primary {
                guard let previewPlayer = self?.previewPlayer else { return }
                guard let track = self?.track else { return }
                let pointA = track.pointA ?? 0.0
                let duration = pointA + CMTimeGetSeconds(previewPlayer.currentTime())
                self?.durationLabel.text = Util.formatDuration(duration)
                self?.durationSlider.value = Float(duration)
            }
        }

        wholePlayer = try? AVAudioPlayer(contentsOf: track.assetURL)

        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    // MARK: - Actions

    @objc func pointAButtonDidTap(sender: Any) {
        track.pointA = wholePlayer?.currentTime
        Playlist.save()

        updatePointLabels()
    }

    @objc func pointBButtonDidTap(sender: Any) {
        track.pointB = wholePlayer?.currentTime
        Playlist.save()

        updatePointLabels()
    }

    @objc func durationSliderDidChange(sender: Any) {
        wholePlayer?.currentTime = TimeInterval(durationSlider.value)
    }

    @objc func playButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.pause()
        previewPlayer?.pause()

        wholePlayer?.play()

        playButton.tintColor = Color.white
        playButton.backgroundColor = Color.primary
        previewButton.tintColor = Color.text
        previewButton.backgroundColor = .clear

        durationSlider.isUserInteractionEnabled = true
        pointAButton.isEnabled = true
        pointAButton.alpha = 1.0
        pointBButton.isEnabled = true
        pointBButton.alpha = 1.0

        pauseButton.isEnabled = true
    }

    @objc func previewButtonDidTap(sender: Any) {
        previewPlayer = AVPlayer(playerItem: track.playerItem)

        BackgroundPlayer.shared.pause()
        wholePlayer?.stop()

        previewPlayer?.play()

        playButton.tintColor = Color.text
        playButton.backgroundColor = .clear
        previewButton.tintColor = Color.white
        previewButton.backgroundColor = Color.primary

        durationSlider.isUserInteractionEnabled = false
        pointAButton.isEnabled = false
        pointAButton.alpha = 0.7
        pointBButton.isEnabled = false
        pointBButton.alpha = 0.7

        pauseButton.isEnabled = true
    }

    @objc func pauseButtonDidTap(sender: Any) {
        wholePlayer?.pause()
        previewPlayer?.pause()

        pauseButton.isEnabled = false
    }

    @objc func appDidEnterBackground(sender: Any) {
        pauseButtonDidTap(sender: self)
    }

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0),
        ])

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0.0),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0),
        ])

        NSLayoutConstraint.activate([
            controlView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
            controlView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            controlView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 8.0),
            durationLabel.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            durationLabel.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            durationLabel.heightAnchor.constraint(equalToConstant: 44.0),
        ])

        NSLayoutConstraint.activate([
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8.0),
            durationSlider.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            durationSlider.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            durationSlider.heightAnchor.constraint(equalToConstant: 44.0),
        ])

        NSLayoutConstraint.activate([
            controlStack.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8.0),
            controlStack.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            controlStack.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            controlStack.heightAnchor.constraint(equalToConstant: 44.0),
            controlStack.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            pointView.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 8.0),
            pointView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            pointView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            pointView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            pointAStack.topAnchor.constraint(equalTo: pointView.topAnchor, constant: 8.0),
            pointAStack.leadingAnchor.constraint(equalTo: pointView.leadingAnchor, constant: 8.0),
            pointAStack.trailingAnchor.constraint(equalTo: pointView.trailingAnchor, constant: -8.0),
            pointAStack.heightAnchor.constraint(equalToConstant: 44.0),
        ])

        NSLayoutConstraint.activate([
            pointBStack.topAnchor.constraint(equalTo: pointAStack.bottomAnchor, constant: 8.0),
            pointBStack.leadingAnchor.constraint(equalTo: pointView.leadingAnchor, constant: 8.0),
            pointBStack.trailingAnchor.constraint(equalTo: pointView.trailingAnchor, constant: -8.0),
            pointBStack.heightAnchor.constraint(equalToConstant: 44.0),
            pointBStack.bottomAnchor.constraint(equalTo: pointView.bottomAnchor, constant: -8.0),
        ])
    }

    func updatePointLabels() {
        if let pointA = track.pointA {
            pointALabel.text = Util.formatDuration(pointA)
        } else {
            pointALabel.text = "-"
        }
        if let pointB = track.pointB {
            pointBLabel.text = Util.formatDuration(pointB)
        } else {
            pointBLabel.text = "-"
        }
    }
}
