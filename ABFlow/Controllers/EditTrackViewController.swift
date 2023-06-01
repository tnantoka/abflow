//
//  EditTrackViewController.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/12.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit
import AVFoundation

class EditTrackViewController: UIViewController { // swiftlint:disable:this type_body_length

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
        let containerView = Util.createView(white: false)
        scrollView.addSubview(containerView)
        return containerView
    }()

    lazy var controlView: UIView = {
        let controlView = Util.createView()
        containerView.addSubview(controlView)
        return controlView
    }()

    lazy var durationLabel: UILabel = {
        let durationLabel = Util.createLabel(center: true)
        durationLabel.backgroundColor = Color.white
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16.0, weight: .regular)
        durationLabel.text = "0:00:00"
        controlView.addSubview(durationLabel)
        return durationLabel
    }()

    lazy var durationSlider: UISlider = {
        let durationSlider = Util.createSlider()
        durationSlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        durationSlider.addTarget(self, action: #selector(durationSliderDidChange), for: .valueChanged)
        controlView.addSubview(durationSlider)
        return durationSlider
    }()

    lazy var playButton: UIButton = {
        let playButton = Util.createButton(title: NSLocalizedString("Play whole", comment: ""))
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        return playButton
    }()

    lazy var pauseButton: UIButton = {
        let pauseButton = Util.createButton(iconCode: "pause")
        pauseButton.addTarget(self, action: #selector(pauseButtonDidTap), for: .touchUpInside)
        pauseButton.isEnabled = false
        return pauseButton
    }()

    lazy var previewButton: UIButton = {
        let previewButton = Util.createButton(title: NSLocalizedString("Preview", comment: ""))
        previewButton.addTarget(self, action: #selector(previewButtonDidTap), for: .touchUpInside)
        return previewButton
    }()

    lazy var controlStack: UIStackView = {
        let controlStack = Util.createStackView([
            playButton,
            pauseButton,
            previewButton
        ], vertical: false)
        controlView.addSubview(controlStack)
        return controlStack
    }()

    lazy var pointAView: UIView = {
        let pointAView = Util.createView()
        containerView.addSubview(pointAView)
        return pointAView
    }()

    lazy var pointAButton: UIButton = {
        let pointAButton = Util.createButton(title: NSLocalizedString("Point A", comment: ""))
        pointAButton.addTarget(self, action: #selector(pointAButtonDidTap), for: .touchUpInside)
        pointAButton.backgroundColor = Color.secondary
        pointAButton.isEnabled = false
        pointAButton.alpha = 0.7
        return pointAButton
    }()

    lazy var pointALabel: UILabel = {
        let pointALabel = Util.createLabel(center: true)
        return pointALabel
    }()

    lazy var pointAClearButton: UIButton = {
        let pointAClearButton = Util.createButton(iconCode: "remove-circle", red: true)
        pointAClearButton.addTarget(self, action: #selector(pointAClearButtonDidTap), for: .touchUpInside)
        pointAClearButton.isEnabled = false
        pointAClearButton.alpha = 0.7
        pointAView.addSubview(pointAClearButton)
        return pointAClearButton
    }()

    lazy var pointAStack: UIStackView = {
        let pointAStack = Util.createStackView([
            pointAButton,
            pointALabel
        ], vertical: false)
        pointAView.addSubview(pointAStack)
        return pointAStack
    }()

    lazy var pointASlider: UISlider = {
        let pointASlider = Util.createSlider()
        pointASlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        pointASlider.addTarget(self, action: #selector(pointASliderDidChange), for: .valueChanged)
        pointASlider.isEnabled = false
        pointAView.addSubview(pointASlider)
        return pointASlider
    }()

    lazy var pointBView: UIView = {
        let pointBView = Util.createView()
        containerView.addSubview(pointBView)
        return pointBView
    }()

    lazy var pointBButton: UIButton = {
        let pointBButton = Util.createButton(title: NSLocalizedString("Point B", comment: ""))
        pointBButton.addTarget(self, action: #selector(pointBButtonDidTap), for: .touchUpInside)
        pointBButton.backgroundColor = Color.secondary
        pointBButton.isEnabled = false
        pointBButton.alpha = 0.7
        return pointBButton
    }()

    lazy var pointBLabel: UILabel = {
        let pointBLabel = Util.createLabel(center: true)
        return pointBLabel
    }()

    lazy var pointBClearButton: UIButton = {
        let pointBClearButton = Util.createButton(iconCode: "remove-circle", red: true)
        pointBClearButton.addTarget(self, action: #selector(pointBClearButtonDidTap), for: .touchUpInside)
        pointBClearButton.isEnabled = false
        pointBClearButton.alpha = 0.7
        pointBView.addSubview(pointBClearButton)
        return pointBClearButton
    }()

    lazy var pointBStack: UIStackView = {
        let pointBStack = Util.createStackView([
            pointBButton,
            pointBLabel
        ], vertical: false)
        pointBView.addSubview(pointBStack)
        return pointBStack
    }()

    lazy var pointBSlider: UISlider = {
        let pointBSlider = Util.createSlider()
        pointBSlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        pointBSlider.addTarget(self, action: #selector(pointBSliderDidChange), for: .valueChanged)
        pointBSlider.isEnabled = false
        pointBView.addSubview(pointBSlider)
        return pointBSlider
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

        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playButtonDidTap(sender: self)
    }

    // MARK: - Actions

    @objc func pointAButtonDidTap(sender: Any) {
        track.update(pointA: wholePlayer?.currentTime)
        updatePointLabels()
    }

    @objc func pointAClearButtonDidTap(sender: Any) {
        track.update(pointA: nil)
        updatePointLabels()
    }

    @objc func pointASliderDidChange(sender: Any) {
        track.update(pointA: Double(pointASlider.value))
        updatePointLabels()
    }

    @objc func pointBButtonDidTap(sender: Any) {
        track.update(pointB: wholePlayer?.currentTime)
        updatePointLabels()
    }

    @objc func pointBClearButtonDidTap(sender: Any) {
        track.update(pointB: nil)
        updatePointLabels()
    }

    @objc func pointBSliderDidChange(sender: Any) {
        track.update(pointB: Double(pointBSlider.value))
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
        pauseButton.isEnabled = true

        updatePointControls(isEnabled: true)
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
        pauseButton.isEnabled = true

        updatePointControls(isEnabled: false)
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

    func buildLayout() { // swiftlint:disable:this function_body_length
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0)
        ])

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0.0),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0)
        ])

        NSLayoutConstraint.activate([
            controlView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
            controlView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            controlView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 8.0),
            durationLabel.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            durationLabel.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            durationLabel.heightAnchor.constraint(equalToConstant: 44.0)
        ])

        NSLayoutConstraint.activate([
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 0.0),
            durationSlider.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            durationSlider.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            durationSlider.heightAnchor.constraint(equalToConstant: 44.0)
        ])

        NSLayoutConstraint.activate([
            controlStack.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 0.0),
            controlStack.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            controlStack.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            controlStack.heightAnchor.constraint(equalToConstant: 44.0),
            controlStack.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            pointAView.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 8.0),
            pointAView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            pointAView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            pointAStack.topAnchor.constraint(equalTo: pointAView.topAnchor, constant: 8.0),
            pointAStack.leadingAnchor.constraint(equalTo: pointAView.leadingAnchor, constant: 8.0),
            pointAStack.heightAnchor.constraint(equalToConstant: 44.0)
        ])

        NSLayoutConstraint.activate([
            pointAClearButton.topAnchor.constraint(equalTo: pointAView.topAnchor, constant: 8.0),
            pointAClearButton.leadingAnchor.constraint(equalTo: pointAStack.trailingAnchor, constant: 8.0),
            pointAClearButton.trailingAnchor.constraint(equalTo: pointAView.trailingAnchor, constant: -8.0),
            pointAClearButton.heightAnchor.constraint(equalToConstant: 44.0),
            pointAClearButton.widthAnchor.constraint(equalToConstant: 44.0)
        ])

        NSLayoutConstraint.activate([
            pointASlider.topAnchor.constraint(equalTo: pointAStack.bottomAnchor, constant: 0.0),
            pointASlider.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            pointASlider.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            pointASlider.heightAnchor.constraint(equalToConstant: 44.0),
            pointASlider.bottomAnchor.constraint(equalTo: pointAView.bottomAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            pointBView.topAnchor.constraint(equalTo: pointAView.bottomAnchor, constant: 8.0),
            pointBView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            pointBView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            pointBView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            pointBStack.topAnchor.constraint(equalTo: pointBView.topAnchor, constant: 8.0),
            pointBStack.leadingAnchor.constraint(equalTo: pointBView.leadingAnchor, constant: 8.0),
            pointBStack.heightAnchor.constraint(equalToConstant: 44.0)
        ])

        NSLayoutConstraint.activate([
            pointBClearButton.topAnchor.constraint(equalTo: pointBView.topAnchor, constant: 8.0),
            pointBClearButton.leadingAnchor.constraint(equalTo: pointBStack.trailingAnchor, constant: 8.0),
            pointBClearButton.trailingAnchor.constraint(equalTo: pointBView.trailingAnchor, constant: -8.0),
            pointBClearButton.heightAnchor.constraint(equalToConstant: 44.0),
            pointBClearButton.widthAnchor.constraint(equalToConstant: 44.0)
        ])

        NSLayoutConstraint.activate([
            pointBSlider.topAnchor.constraint(equalTo: pointBStack.bottomAnchor, constant: 0.0),
            pointBSlider.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8.0),
            pointBSlider.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -8.0),
            pointBSlider.heightAnchor.constraint(equalToConstant: 44.0),
            pointBSlider.bottomAnchor.constraint(equalTo: pointBView.bottomAnchor, constant: -8.0)
        ])
    }

    func updatePointLabels() {
        if let pointA = track.pointA {
            pointALabel.text = Util.formatDuration(pointA)
            pointASlider.value = Float(pointA)
        } else {
            pointALabel.text = "-"
            pointASlider.value = 0.0
        }
        if let pointB = track.pointB {
            pointBLabel.text = Util.formatDuration(pointB)
            pointBSlider.value = Float(pointB)
        } else {
            pointBLabel.text = "-"
            pointBSlider.value = 0.0
        }
    }

    func updatePointControls(isEnabled: Bool) {
        let alpha: CGFloat = isEnabled ? 1.0 : 0.7

        pointAButton.isEnabled = isEnabled
        pointAButton.alpha = alpha
        pointAClearButton.isEnabled = isEnabled
        pointAClearButton.alpha = alpha
        pointASlider.isEnabled = isEnabled

        pointBButton.isEnabled = isEnabled
        pointBButton.alpha = alpha
        pointBClearButton.isEnabled = isEnabled
        pointBClearButton.alpha = alpha
        pointBSlider.isEnabled = isEnabled
    }
} // swiftlint:disable:this file_length
