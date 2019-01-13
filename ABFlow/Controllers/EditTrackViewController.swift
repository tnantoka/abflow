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

    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.backgroundColor = Color.white
        durationLabel.textAlignment = .center
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
        durationLabel.textColor = Color.text

        view.addSubview(durationLabel)

        return durationLabel
    }()

    lazy var sectionViewA: UIView = {
        let sectionViewA = UIView(frame: .zero)

        sectionViewA.translatesAutoresizingMaskIntoConstraints = false
        sectionViewA.backgroundColor = Color.white

        view.addSubview(sectionViewA)

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

        view.addSubview(sectionViewB)

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

        view.addSubview(sectionViewPreview)

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
        }

        wholePlayer = try? AVAudioPlayer(contentsOf: track.assetURL)
        wholePlayer?.play()
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

        wholePlayer?.stop()
        previewPlayer?.play()
    }

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            durationLabel.heightAnchor.constraint(equalToConstant: 44.0),
        ])

        NSLayoutConstraint.activate([
            sectionViewA.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8.0),
            sectionViewA.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            sectionViewA.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            sectionViewA.heightAnchor.constraint(equalToConstant: 44.0),
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
            sectionViewB.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            sectionViewB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            sectionViewB.heightAnchor.constraint(equalToConstant: 44.0),
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
            sectionViewPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            sectionViewPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            sectionViewPreview.heightAnchor.constraint(equalToConstant: 44.0),
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
