//
//  PlaylistModalViewController.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/15.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit
import AVFoundation

class PlaylistModalViewController: UIViewController {

    let playlist: Playlist

    var containerHeight: CGFloat = 0.0
    var containerBottomConstraint: NSLayoutConstraint?
    var playerTimer: Timer?

    lazy var durationSlider: UISlider = {
        let durationSlider = UISlider(frame: .zero)

        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.isContinuous = false
        durationSlider.minimumValue = 0.0
        durationSlider.addTarget(self, action: #selector(durationSliderDidChange), for: .valueChanged)
        durationSlider.tintColor = Color.text
        durationSlider.thumbTintColor = Color.primary

        return durationSlider
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

    lazy var prevButton: UIButton = {
        let prevButton = UIButton(type: .system)

        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.addTarget(self, action: #selector(prevButtonDidTap), for: .touchUpInside)
        prevButton.tintColor = Color.text

        let prevImage = UIImage(from: .materialIcon, code: "fast.rewind", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        prevButton.setImage(prevImage, for: .normal)

        return prevButton
    }()

    lazy var nextButton: UIButton = {
        let nextButton = UIButton(type: .system)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        nextButton.tintColor = Color.text

        let nextImage = UIImage(from: .materialIcon, code: "fast.forward", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        nextButton.setImage(nextImage, for: .normal)

        return nextButton
    }()

    lazy var pauseButton: UIButton = {
        let pauseButton = UIButton(type: .system)

        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.addTarget(self, action: #selector(pauseButtonDidTap), for: .touchUpInside)
        pauseButton.tintColor = Color.text

        let pauseImage = UIImage(from: .materialIcon, code: "pause", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        pauseButton.setImage(pauseImage, for: .normal)

        return pauseButton
    }()

    lazy var controlStack: UIStackView = {
        let controlStack = UIStackView(arrangedSubviews: [
            prevButton,
            playButton,
            pauseButton,
            nextButton,
        ])

        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.axis = .horizontal
        controlStack.distribution = .fillEqually

        return controlStack
    }()

    lazy var repeatButton: UIButton = {
        let repeatButton = UIButton(type: .system)

        repeatButton.translatesAutoresizingMaskIntoConstraints = false
        repeatButton.addTarget(self, action: #selector(repeatButtonDidTap), for: .touchUpInside)
        repeatButton.tintColor = Color.text

        let repeatImage = UIImage(from: .materialIcon, code: "repeat", textColor: .black, backgroundColor: .clear, size: CGSize(width: 32.0, height: 32.0))
        repeatButton.setImage(repeatImage, for: .normal)

        return repeatButton
    }()

    lazy var speedButton: UIButton = {
        let speedButton = UIButton(type: .system)

        speedButton.translatesAutoresizingMaskIntoConstraints = false
        speedButton.addTarget(self, action: #selector(speedButtonDidTap), for: .touchUpInside)
        speedButton.tintColor = Color.text
        speedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)

        return speedButton
    }()

    lazy var modeStack: UIStackView = {
        let modeStack = UIStackView(arrangedSubviews: [
            repeatButton,
            speedButton,
        ])

        modeStack.translatesAutoresizingMaskIntoConstraints = false
        modeStack.axis = .horizontal
        modeStack.distribution = .fillEqually

        return modeStack
    }()


    lazy var playlistBar: PlaylistBar = {
        let playlistBar = PlaylistBar(frame: .zero)

        playlistBar.onTapLabel = { [weak self] in
            self?.viewDidTap(sender: playlistBar)
        }

        view.addSubview(playlistBar)

        return playlistBar
    }()

    lazy var containerStack: UIStackView = {
        let containerStack = UIStackView(arrangedSubviews: [
            durationSlider,
            controlStack,
            modeStack,
        ])

        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.distribution = .fillEqually

        containerView.addSubview(containerStack)

        return containerStack
    }()

    lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Color.secondary

        view.addSubview(containerView)

        return containerView
    }()

    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        view.addGestureRecognizer(tapRecognizer)

        buildLayout()

        playerTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateControls()
        }
        updateControls()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        containerBottomConstraint?.constant = 0.0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.view.backgroundColor = Color.darkGray.withAlphaComponent(0.7)
        }
    }
    
    // MARK: - Actions

    @objc func viewDidTap(sender: Any) {
        containerBottomConstraint?.constant = containerHeight
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
                self?.view.backgroundColor = Color.darkGray.withAlphaComponent(0.0)
            },
            completion: { [weak self] _ in
                self?.presentingViewController?.dismiss(animated: false, completion: nil)
            }
        )
    }

    @objc func playButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.play()
    }

    @objc func pauseButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.pause()
    }

    @objc func prevButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.prev()
    }

    @objc func nextButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.next()
    }

    @objc func repeatButtonDidTap(sender: Any) {
        print("repeat")
    }

    @objc func speedButtonDidTap(sender: Any) {
        BackgroundPlayer.shared.changeSpeed()
    }

    @objc func durationSliderDidChange(sender: Any) {
        guard let currentItem = BackgroundPlayer.shared.currentItem else { return }
        let time = CMTime(seconds: Double(durationSlider.value), preferredTimescale: currentItem.duration.timescale)
        BackgroundPlayer.shared.avPlayer?.seek(to: time)
    }

    // MARK: - Utils

    func buildLayout() {
        containerHeight = 60.0 * CGFloat(containerStack.arrangedSubviews.count)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
        ])

        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: playlistBar.topAnchor, constant: containerHeight)
        containerBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
            containerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
            containerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
            containerStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8.0)
        ])

        NSLayoutConstraint.activate([
            playlistBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            playlistBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            playlistBar.heightAnchor.constraint(equalToConstant: 60.0),
            playlistBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0)
        ])
    }

    func updateControls() {
        durationSlider.maximumValue = Float(BackgroundPlayer.shared.currentDuration)
        durationSlider.value = BackgroundPlayer.shared.currentTime

        speedButton.setTitle("\(BackgroundPlayer.shared.speed)x", for: .normal)

        if BackgroundPlayer.shared.isPlaying {
            playButton.isHidden = true
            pauseButton.isHidden = false
        } else {
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
}
