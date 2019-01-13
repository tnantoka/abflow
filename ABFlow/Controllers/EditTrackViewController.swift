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

    lazy var sectionViewControl: UIView = {
        let sectionViewControl = UIView(frame: .zero)

        sectionViewControl.translatesAutoresizingMaskIntoConstraints = false
        sectionViewControl.backgroundColor = Color.white

        containerView.addSubview(sectionViewControl)

        return sectionViewControl
    }()

    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.backgroundColor = Color.white
        durationLabel.textAlignment = .center
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
        durationLabel.textColor = Color.text
        durationLabel.text = "0:00:00"

        sectionViewControl.addSubview(durationLabel)

        return durationLabel
    }()

    lazy var playButton: UIButton = {
        let playButton = UIButton(type: .system)

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        playButton.tintColor = Color.text

        let playImage = UIImage(from: .materialIcon, code: "play.arrow", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        playButton.setImage(playImage, for: .normal)

        sectionViewControl.addSubview(playButton)

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

        sectionViewControl.addSubview(pauseButton)

        return pauseButton
    }()

    lazy var durationSlider: UISlider = {
        let durationSlider = UISlider(frame: .zero)

        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.isContinuous = false
        durationSlider.minimumValue = 0.0
        durationSlider.maximumValue = Float(CMTimeGetSeconds(track.asset.duration))
        durationSlider.addTarget(self, action: #selector(durationSliderDidChange), for: .valueChanged)

        sectionViewControl.addSubview(durationSlider)

        return durationSlider
    }()

    lazy var sectionViewA: UIView = {
        let sectionViewA = UIView(frame: .zero)

        sectionViewA.translatesAutoresizingMaskIntoConstraints = false
        sectionViewA.backgroundColor = Color.white

        containerView.addSubview(sectionViewA)

        return sectionViewA
    }()

    lazy var pointButtonA: UIButton = {
        let pointButtonA = UIButton(type: .system)

        pointButtonA.translatesAutoresizingMaskIntoConstraints = false
        pointButtonA.setTitle(NSLocalizedString("Point A", comment: ""), for: .normal)
        pointButtonA.addTarget(self, action: #selector(pointButtonADidTap), for: .touchUpInside)
        pointButtonA.setTitleColor(Color.text, for: .normal)
        pointButtonA.backgroundColor = Color.secondary

        sectionViewA.addSubview(pointButtonA)

        return pointButtonA
    }()

    lazy var pointLabelA: UILabel = {
        let pointLabelA = UILabel(frame: .zero)

        pointLabelA.translatesAutoresizingMaskIntoConstraints = false
        pointLabelA.textColor = Color.text

        sectionViewA.addSubview(pointLabelA)

        return pointLabelA
    }()

    lazy var sectionViewB: UIView = {
        let sectionViewB = UIView(frame: .zero)

        sectionViewB.translatesAutoresizingMaskIntoConstraints = false
        sectionViewB.backgroundColor = Color.white

        containerView.addSubview(sectionViewB)

        return sectionViewB
    }()

    lazy var pointButtonB: UIButton = {
        let pointButtonB = UIButton(type: .system)

        pointButtonB.translatesAutoresizingMaskIntoConstraints = false
        pointButtonB.setTitle(NSLocalizedString("Point B", comment: ""), for: .normal)
        pointButtonB.addTarget(self, action: #selector(pointButtonBDidTap), for: .touchUpInside)
        pointButtonB.setTitleColor(Color.text, for: .normal)
        pointButtonB.backgroundColor = Color.secondary

        sectionViewB.addSubview(pointButtonB)

        return pointButtonB
    }()

    lazy var pointLabelB: UILabel = {
        let pointLabelB = UILabel(frame: .zero)

        pointLabelB.translatesAutoresizingMaskIntoConstraints = false
        pointLabelB.textColor = Color.text

        sectionViewB.addSubview(pointLabelB)

        return pointLabelB
    }()

    lazy var sectionViewPreview: UIView = {
        let sectionViewPreview = UIView(frame: .zero)

        sectionViewPreview.translatesAutoresizingMaskIntoConstraints = false
        sectionViewPreview.backgroundColor = Color.white

        containerView.addSubview(sectionViewPreview)

        return sectionViewPreview
    }()

    lazy var previewButton: UIButton = {
        let previewButton = UIButton(type: .system)

        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.setTitle(NSLocalizedString("Preview", comment: ""), for: .normal)
        previewButton.addTarget(self, action: #selector(previewButtonDidTap), for: .touchUpInside)
        previewButton.setTitleColor(Color.white, for: .normal)
        previewButton.backgroundColor = Color.primary

        sectionViewPreview.addSubview(previewButton)

        return previewButton
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

        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let wholePlayer = self?.wholePlayer else { return }

            self?.durationLabel.text = Util.formatDuration(wholePlayer.currentTime)
            self?.durationSlider.value = Float(wholePlayer.currentTime)
        }

        wholePlayer = try? AVAudioPlayer(contentsOf: track.assetURL)

        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    // MARK: - Actions

    @objc func pointButtonADidTap(sender: Any) {
        track.pointA = wholePlayer?.currentTime
        Playlist.save()

        updatePointLabels()
    }

    @objc func pointButtonBDidTap(sender: Any) {
        track.pointB = wholePlayer?.currentTime
        Playlist.save()

        updatePointLabels()
    }

    @objc func previewButtonDidTap(sender: Any) {
        previewPlayer = AVPlayer(playerItem: track.playerItem)

        BackgroundPlayer.shared.pause()
        wholePlayer?.stop()

        previewPlayer?.play()
    }

    @objc func durationSliderDidChange(sender: Any) {
        wholePlayer?.currentTime = TimeInterval(durationSlider.value)
    }

    @objc func playButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.pause()
        previewPlayer?.pause()

        wholePlayer?.play()

        playButton.isHidden = true
        pauseButton.isHidden = false
    }

    @objc func pauseButtonDidTap(sender: Any) {
        wholePlayer?.pause()

        playButton.isHidden = false
        pauseButton.isHidden = true
    }

    @objc func appDidEnterBackground(sender: Any) {
        pauseButtonDidTap(sender: self)

        previewPlayer?.pause()
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
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0),
        ])

        NSLayoutConstraint.activate([
            sectionViewControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
            sectionViewControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            sectionViewControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            sectionViewControl.heightAnchor.constraint(equalToConstant: 44.0 * 3.0 + 8.0 * 4.0),
        ])

        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: sectionViewControl.topAnchor, constant: 8.0),
            durationLabel.leadingAnchor.constraint(equalTo: sectionViewControl.leadingAnchor, constant: 8.0),
            durationLabel.trailingAnchor.constraint(equalTo: sectionViewControl.trailingAnchor, constant: -8.0),
            durationLabel.heightAnchor.constraint(equalToConstant: 44.0),
        ])

        NSLayoutConstraint.activate([
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8.0),
            durationSlider.leadingAnchor.constraint(equalTo: sectionViewControl.leadingAnchor, constant: 8.0),
            durationSlider.trailingAnchor.constraint(equalTo: sectionViewControl.trailingAnchor, constant: -8.0),
            durationSlider.heightAnchor.constraint(equalToConstant: 44.0),
        ])

        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8.0),
            playButton.widthAnchor.constraint(equalToConstant: 44.0),
            playButton.heightAnchor.constraint(equalToConstant: 44.0),
            playButton.centerXAnchor.constraint(equalToSystemSpacingAfter: sectionViewControl.centerXAnchor, multiplier: 0.0)
        ])

        NSLayoutConstraint.activate([
            pauseButton.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8.0),
            pauseButton.widthAnchor.constraint(equalToConstant: 44.0),
            pauseButton.heightAnchor.constraint(equalToConstant: 44.0),
            pauseButton.centerXAnchor.constraint(equalToSystemSpacingAfter: sectionViewControl.centerXAnchor, multiplier: 0.0)
        ])

        NSLayoutConstraint.activate([
            sectionViewA.topAnchor.constraint(equalTo: sectionViewControl.bottomAnchor, constant: 8.0),
            sectionViewA.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            sectionViewA.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            sectionViewA.heightAnchor.constraint(equalToConstant: 44.0 * 1.0 + 8.0 * 2.0),
        ])

        NSLayoutConstraint.activate([
            pointButtonA.topAnchor.constraint(equalTo: sectionViewA.topAnchor, constant: 8.0),
            pointButtonA.leadingAnchor.constraint(equalTo: sectionViewA.leadingAnchor, constant: 8.0),
            pointButtonA.trailingAnchor.constraint(equalTo: sectionViewA.centerXAnchor, constant: -4.0),
            pointButtonA.bottomAnchor.constraint(equalTo: sectionViewA.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            pointLabelA.topAnchor.constraint(equalTo: sectionViewA.topAnchor, constant: 8.0),
            pointLabelA.leadingAnchor.constraint(equalTo: sectionViewA.centerXAnchor, constant: 4.0),
            pointLabelA.trailingAnchor.constraint(equalTo: sectionViewA.trailingAnchor, constant: -8.0),
            pointLabelA.bottomAnchor.constraint(equalTo: sectionViewA.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            sectionViewB.topAnchor.constraint(equalTo: sectionViewA.bottomAnchor, constant: 8.0),
            sectionViewB.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            sectionViewB.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            sectionViewB.heightAnchor.constraint(equalToConstant: 44.0 * 1.0 + 8.0 * 2.0),
        ])

        NSLayoutConstraint.activate([
            pointButtonB.topAnchor.constraint(equalTo: sectionViewB.topAnchor, constant: 8.0),
            pointButtonB.leadingAnchor.constraint(equalTo: sectionViewB.leadingAnchor, constant: 8.0),
            pointButtonB.trailingAnchor.constraint(equalTo: sectionViewB.centerXAnchor, constant: -4.0),
            pointButtonB.bottomAnchor.constraint(equalTo: sectionViewB.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            pointLabelB.topAnchor.constraint(equalTo: sectionViewB.topAnchor, constant: 8.0),
            pointLabelB.leadingAnchor.constraint(equalTo: sectionViewB.centerXAnchor, constant: 4.0),
            pointLabelB.trailingAnchor.constraint(equalTo: sectionViewB.trailingAnchor, constant: -8.0),
            pointLabelB.bottomAnchor.constraint(equalTo: sectionViewB.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            sectionViewPreview.topAnchor.constraint(equalTo: sectionViewB.bottomAnchor, constant: 8.0),
            sectionViewPreview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            sectionViewPreview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            sectionViewPreview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0),
        ])

        NSLayoutConstraint.activate([
            previewButton.topAnchor.constraint(equalTo: sectionViewPreview.topAnchor, constant: 8.0),
            previewButton.leadingAnchor.constraint(equalTo: sectionViewPreview.leadingAnchor, constant: 8.0),
            previewButton.trailingAnchor.constraint(equalTo: sectionViewPreview.trailingAnchor, constant: -8.0),
            previewButton.bottomAnchor.constraint(equalTo: sectionViewPreview.bottomAnchor, constant: -8.0),
        ])
    }

    func updatePointLabels() {
        pointLabelA.text = Util.formatDuration(track.pointA)
        pointLabelB.text = Util.formatDuration(track.pointB)
    }
}
