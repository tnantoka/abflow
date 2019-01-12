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
    let tableView = UITableView(frame: .zero)

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

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0.0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0.0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0)
        ])

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemDidTap))
        navigationItem.rightBarButtonItem = addItem
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

    // MARK: - Utils

    func refresh() {
        tableView.reloadData()
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
        cell.textLabel?.text = track.title

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
