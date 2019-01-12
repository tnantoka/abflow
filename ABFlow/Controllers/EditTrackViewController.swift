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

    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.backgroundColor = Color.white
        durationLabel.textAlignment = .center
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)
        durationLabel.textAlignment = .center

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

        sectionViewA.addSubview(pointButtonA)

        return pointButtonA
    }()

    lazy var pointTextA: UITextField = {
        let pointTextA = UITextField(frame: .zero)

        pointTextA.translatesAutoresizingMaskIntoConstraints = false
        if let pointA = track.pointA {
            pointTextA.text = String(pointA)
        }

        sectionViewA.addSubview(pointTextA)

        return pointTextA
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

        sectionViewB.addSubview(pointButtonB)

        return pointButtonB
    }()

    lazy var pointTextB: UITextField = {
        let pointTextB = UITextField(frame: .zero)

        pointTextB.translatesAutoresizingMaskIntoConstraints = false
        if let pointB = track.pointB {
            pointTextB.text = String(pointB)
        }

        sectionViewB.addSubview(pointTextB)

        return pointTextB
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

        view.backgroundColor = Color.lightGray

        let previewItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(previewItemDidTap))
        toolbarItems = [previewItem]

        buildLayout()

        wholePlayer = try? AVAudioPlayer(contentsOf: track.assetURL)
        wholePlayer?.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setToolbarHidden(true, animated: animated)
    }

    // MARK: - Actions

    @objc func pointButtonADidTap(sender: Any) {
        pointTextA.text = String(wholePlayer?.currentTime ?? 0)

        track.pointA = wholePlayer?.currentTime
        Playlist.save()
    }

    @objc func pointButtonBDidTap(sender: Any) {
        pointTextB.text = String(wholePlayer?.currentTime ?? 0)
        track.pointB = wholePlayer?.currentTime
        Playlist.save()
    }

    @objc func previewItemDidTap(sender: Any) {
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
            pointTextA.topAnchor.constraint(equalTo: sectionViewA.topAnchor, constant: 8.0),
            pointTextA.leadingAnchor.constraint(equalTo: sectionViewA.centerXAnchor, constant: 4.0),
            pointTextA.trailingAnchor.constraint(equalTo: sectionViewA.trailingAnchor, constant: -8.0),
            pointTextA.bottomAnchor.constraint(equalTo: sectionViewA.bottomAnchor, constant: -8.0),
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
            pointTextB.topAnchor.constraint(equalTo: sectionViewB.topAnchor, constant: 8.0),
            pointTextB.leadingAnchor.constraint(equalTo: sectionViewB.centerXAnchor, constant: 4.0),
            pointTextB.trailingAnchor.constraint(equalTo: sectionViewB.trailingAnchor, constant: -8.0),
            pointTextB.bottomAnchor.constraint(equalTo: sectionViewB.bottomAnchor, constant: -8.0),
        ])
    }
}
