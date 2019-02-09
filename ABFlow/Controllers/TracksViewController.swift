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
    let itemSize = CGSize(width: 28.0, height: 28.0)

    let playlist: Playlist
    var barBottomConstraint: NSLayoutConstraint?
    var alertTopConstraint: NSLayoutConstraint?

    lazy var alertView: UIView = {
        let alertView = Util.createView()
        view.addSubview(alertView)
        return alertView
    }()

    lazy var alertLabel: UILabel = {
        let alertLabel = Util.createLabel(center: true)
        alertLabel.text = NSLocalizedString("No tracks yet.", comment: "")
        return alertLabel
    }()

    lazy var alertButton: UIButton = {
        let alertButton = Util.createButton(title: NSLocalizedString("Add New Track", comment: ""))
        alertButton.addTarget(self, action: #selector(alertButtonDidTap), for: .touchUpInside)
        alertButton.backgroundColor = Color.secondary
        return alertButton
    }()

    lazy var alertStack: UIStackView = {
        let alertStack = Util.createStackView([
            alertLabel,
            alertButton
        ])
        alertView.addSubview(alertStack)
        return alertStack
    }()

    lazy var tableView: UITableView = {
        let tableView = Util.createTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        return tableView
    }()

    lazy var playlistBar: PlaylistBar = {
        let playlistBar = PlaylistBar(frame: .zero)

        playlistBar.onTapLabel = { [weak self] in
            guard let playlist = self?.playlist else { return }
            let modalController = PlaylistModalViewController(playlist: playlist)
            self?.present(modalController, animated: false, completion: nil)
        }

        view.addSubview(playlistBar)

        return playlistBar
    }()

    lazy var addItem: UIBarButtonItem = {
        Util.createBarButtonItem(iconCode: "playlist.add", target: self, action: #selector(addItemDidTap))
    }()

    lazy var editItem: UIBarButtonItem = {
        Util.createBarButtonItem(iconCode: "edit", target: self, action: #selector(editItemDidTap))
    }()

    lazy var doneItem: UIBarButtonItem = {
        Util.createBarButtonItem(iconCode: "close", target: self, action: #selector(doneItemDidTap))
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

        setEditing(false, animated: false)

        buildLayout()

        NotificationCenter.default.addObserver(self, selector: #selector(updateCells),
                                               name: BackgroundPlayer.changeTrackNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaylistBar),
                                               name: BackgroundPlayer.changePlaylistNotification, object: nil)

        updatePlaylistBar()
        updateAlertView()
        updateBarItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateCells()
        deselectRow(animated: animated)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            navigationItem.rightBarButtonItems = [doneItem]
        } else {
            navigationItem.rightBarButtonItems = [editItem, addItem]
        }

        tableView.setEditing(editing, animated: animated)

        if editing && !Settings.shared.tracksEdited {
            let alertController = UIAlertController(
                title: NSLocalizedString("Edit Tracks", comment: ""),
                message: NSLocalizedString("Please tap the cell to configure settings for the track.", comment: ""),
                preferredStyle: .alert
            )
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            )
            present(alertController, animated: true, completion: nil)

            Settings.shared.tracksEdited = true
        }
    }

    // MARK: - Actions

    @objc func addItemDidTap(sender: Any) {
        if Settings.shared.tracksAdded {
            showMediaPicker()
        } else {
            let alertController = UIAlertController(
                title: NSLocalizedString("Add Tracks", comment: ""),
                message: NSLocalizedString("There are some formats that are not supported, such as DRM-protected songs.", comment: ""), // swiftlint:disable:this line_length
                preferredStyle: .alert
            )
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default,
                              handler: { [weak self] _ in self?.showMediaPicker() })
            )
            present(alertController, animated: true, completion: nil)

            Settings.shared.tracksAdded = true
        }
    }

    @objc func editItemDidTap(sender: Any) {
        setEditing(true, animated: true)
    }

    @objc func doneItemDidTap(sender: Any) {
        setEditing(false, animated: true)
    }

    @objc func alertButtonDidTap(sender: Any) {
        addItemDidTap(sender: sender)
    }

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            alertView.heightAnchor.constraint(equalToConstant: 88.0)
        ])

        alertTopConstraint = alertView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0)
        alertTopConstraint?.isActive = true

        NSLayoutConstraint.activate([
            alertStack.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 8.0),
            alertStack.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 8.0),
            alertStack.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -8.0),
            alertStack.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -8.0)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: alertView.bottomAnchor, constant: 4.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4.0)
        ])

        NSLayoutConstraint.activate([
            playlistBar.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0.0),
            playlistBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            playlistBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            playlistBar.heightAnchor.constraint(equalToConstant: 60.0)
        ])

        barBottomConstraint = playlistBar.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 60.0
        )
        barBottomConstraint?.isActive = true
    }

    func refresh() {
        tableView.reloadData()
        updateAlertView()
        updateBarItems()
    }

    func deselectRow(animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    @objc func updateCells() {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                let track = playlist.tracks[indexPath.row]
                configureCell(cell, with: track)
            }
        }
    }

    @objc func updatePlaylistBar() {
        barBottomConstraint?.constant = BackgroundPlayer.shared.playlist == nil ? 60.0 : 0.0
    }

    func updateAlertView() {
        if playlist.tracks.isEmpty {
            alertTopConstraint?.constant = 8.0
        } else {
            alertTopConstraint?.constant = -88.0
        }
    }

    func updateBarItems() {
        editItem.isEnabled = !playlist.tracks.isEmpty
    }

    func showMediaPicker() {
        if MPMediaLibrary.authorizationStatus() == .denied {
            let alertController = UIAlertController(
                title: NSLocalizedString("Add Tracks", comment: ""),
                message: NSLocalizedString("There is no permission to access the media library. Please allow it in the settings app.", comment: ""), // swiftlint:disable:this line_length
                preferredStyle: .alert
            )
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            )
            present(alertController, animated: true, completion: nil)

            return
        }

        let mediaController = MPMediaPickerController()
        mediaController.delegate = self
        mediaController.allowsPickingMultipleItems = true
        mediaController.showsItemsWithProtectedAssets = false
        mediaController.showsCloudItems = false

        present(mediaController, animated: true, completion: nil)
    }
}

extension TracksViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
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
        guard let cell = cell as? ItemCell else { return }

        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = "\(Util.formatDuration(track.pointA)) - \(Util.formatDuration(track.pointB))"

        cell.isPlaying = BackgroundPlayer.shared.track?.id == track.id
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let track = playlist.tracks[indexPath.row]
            let editTrackController = EditTrackViewController(track: track)
            navigationController?.pushViewController(editTrackController, animated: true)
        } else {
            BackgroundPlayer.shared.playlist = playlist
            BackgroundPlayer.shared.play(index: indexPath.row)
            BackgroundPlayer.shared.play()
            deselectRow(animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let isUsing = BackgroundPlayer.shared.playlist?.id == playlist.id
            if isUsing {
                BackgroundPlayer.shared.playlist = nil
            }

            let track = playlist.tracks[indexPath.row]
            playlist.destroyTrack(track)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateAlertView()
                self?.updateBarItems()
            }

            if isUsing && !playlist.tracks.isEmpty {
                BackgroundPlayer.shared.playlist = playlist
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let track = playlist.tracks[sourceIndexPath.row]
        playlist.moveTrack(track, to: destinationIndexPath.row)
        tableView.reloadData()

        if BackgroundPlayer.shared.playlist?.id == playlist.id {
            BackgroundPlayer.shared.playlist = playlist
        }
    }
}
