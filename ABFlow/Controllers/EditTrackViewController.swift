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

        let pauseImage = UIImage(from: .materialIcon, code: "pause", textColor: .black,
                                 backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
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
            previewButton
        ])

        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.axis = .horizontal
        controlStack.distribution = .fillEqually

        controlView.addSubview(controlStack)

        return controlStack
    }()

    lazy var pointAView: UIView = {
        let pointAView = Util.createView()
        containerView.addSubview(pointAView)
        return pointAView
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
        let pointALabel = Util.createLabel(center: true)
        return pointALabel
    }()

    lazy var pointAClearButton: UIButton = {
        let pointAClearButton = UIButton(type: .system)

        pointAClearButton.translatesAutoresizingMaskIntoConstraints = false
        pointAClearButton.addTarget(self, action: #selector(pointAClearButtonDidTap), for: .touchUpInside)
        pointAClearButton.tintColor = Color.red
        pointAClearButton.isEnabled = false
        pointAClearButton.alpha = 0.7

        let removeImage = UIImage(from: .materialIcon, code: "remove.circle", textColor: .black,
                                 backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        pointAClearButton.setImage(removeImage, for: .normal)

        pointAView.addSubview(pointAClearButton)

        return pointAClearButton
    }()

    lazy var pointAStack: UIStackView = {
        let pointAStack = UIStackView(arrangedSubviews: [
            pointAButton,
            pointALabel
        ])

        pointAStack.translatesAutoresizingMaskIntoConstraints = false
        pointAStack.axis = .horizontal
        pointAStack.distribution = .fillEqually

        pointAView.addSubview(pointAStack)

        return pointAStack
    }()

    lazy var pointASlider: UISlider = {
        let pointASlider = UISlider(frame: .zero)

        pointASlider.translatesAutoresizingMaskIntoConstraints = false
        pointASlider.isContinuous = false
        pointASlider.minimumValue = 0.0
        pointASlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        pointASlider.addTarget(self, action: #selector(pointASliderDidChange), for: .valueChanged)
        pointASlider.tintColor = Color.text
        pointASlider.thumbTintColor = Color.primary
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
        let pointBLabel = Util.createLabel(center: true)
        return pointBLabel
    }()

    lazy var pointBClearButton: UIButton = {
        let pointBClearButton = UIButton(type: .system)

        pointBClearButton.translatesAutoresizingMaskIntoConstraints = false
        pointBClearButton.addTarget(self, action: #selector(pointBClearButtonDidTap), for: .touchUpInside)
        pointBClearButton.tintColor = Color.red
        pointBClearButton.isEnabled = false
        pointBClearButton.alpha = 0.7

        let removeImage = UIImage(from: .materialIcon, code: "remove.circle", textColor: .black,
                                  backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        pointBClearButton.setImage(removeImage, for: .normal)

        pointBView.addSubview(pointBClearButton)

        return pointBClearButton
    }()

    lazy var pointBStack: UIStackView = {
        let pointBStack = UIStackView(arrangedSubviews: [
            pointBButton,
            pointBLabel
        ])

        pointBStack.translatesAutoresizingMaskIntoConstraints = false
        pointBStack.axis = .horizontal
        pointBStack.distribution = .fillEqually

        pointBView.addSubview(pointBStack)

        return pointBStack
    }()

    lazy var pointBSlider: UISlider = {
        let pointBSlider = UISlider(frame: .zero)

        pointBSlider.translatesAutoresizingMaskIntoConstraints = false
        pointBSlider.isContinuous = false
        pointBSlider.minimumValue = 0.0
        pointBSlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        pointBSlider.addTarget(self, action: #selector(pointBSliderDidChange), for: .valueChanged)
        pointBSlider.tintColor = Color.text
        pointBSlider.thumbTintColor = Color.primary
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
        pointAButton.isEnabled = true
        pointAButton.alpha = 1.0
        pointAClearButton.isEnabled = true
        pointAClearButton.alpha = 1.0
        pointASlider.isEnabled = true

        pointBButton.isEnabled = true
        pointBButton.alpha = 1.0
        pointBClearButton.isEnabled = true
        pointBClearButton.alpha = 1.0
        pointBSlider.isEnabled = true

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
        pointAClearButton.isEnabled = false
        pointAClearButton.alpha = 0.7
        pointASlider.isEnabled = false

        pointBButton.isEnabled = false
        pointBButton.alpha = 0.7
        pointBClearButton.isEnabled = false
        pointBClearButton.alpha = 0.7
        pointBSlider.isEnabled = false

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
}
