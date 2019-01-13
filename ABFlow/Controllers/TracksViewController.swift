//
//  TracksViewController.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/11.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit
import MediaPlayer

class TracksViewController: UIViewController {
    let cellIdentifier = "TrackCell"

    let playlist: Playlist

    var repeatPlayer: AVPlayer?
    var playerItems = [AVPlayerItem]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = Color.darkGray

        view.addSubview(tableView)

        return tableView
    }()

    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = playlist.name

        view.backgroundColor = Color.darkGray

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemDidTap))
        navigationItem.rightBarButtonItem = addItem

        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                let track = playlist.tracks[indexPath.row]
                configureCell(cell, with: track)
            }
        }

        navigationController?.setToolbarHidden(false, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setToolbarHidden(true, animated: animated)
    }

    // MARK: - Actions

    @objc func addItemDidTap(sender: Any) {
        let mediaController = MPMediaPickerController()
        mediaController.delegate = self
        mediaController.allowsPickingMultipleItems = true
        mediaController.showsItemsWithProtectedAssets = false
        mediaController.showsCloudItems = false
        present(mediaController, animated: true, completion: nil)
    }

    @objc func playerItemDidEnd(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }

        if playerItem == playerItems.last {
            playAll()
        }
    }

    @objc func playButtonDidTap(sender: Any) {
        playAll()
    }

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4.0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 4.0)
        ])
    }

    func refresh() {
        tableView.reloadData()
    }

    func playAll() {
        playerItems = playlist.tracks.map { $0.playerItem }
        repeatPlayer = AVQueuePlayer(items: playerItems)
        repeatPlayer?.play()
    }
}

extension TracksViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard mediaItemCollection.count > 0 else { return }

        let tracks: [Track] = mediaItemCollection.items.map { item in
            guard let assetURL = item.assetURL else { return nil }
            guard let title = item.title else { return nil }
            return Track(title: title, assetURL: assetURL)
        }.compactMap { $0 }
        guard tracks.count > 0 else { return }

        playlist.appendTracks(tracks)
        refresh()

        dismiss(animated: true, completion: nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension TracksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let track = playlist.tracks[indexPath.row]
        configureCell(cell, with: track)

        return cell
    }

    func configureCell(_ cell: UITableViewCell, with track: Track) {
        cell.textLabel?.text = track.title
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = "\(Util.formatDuration(track.pointA)) - \(Util.formatDuration(track.pointB))"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = playlist.tracks[indexPath.row]
        let editTrackController = EditTrackViewController(track: track)
        navigationController?.pushViewController(editTrackController, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let track = playlist.tracks[indexPath.row]
            playlist.destroyTrack(track)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
