//
//  PlaylistsViewController.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/10.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

import SwiftIconFont

class PlaylistsViewController: UIViewController {
    let cellIdentifier = "PlaylistCell"

    var playlists = Playlist.all
    var barBottomConstraint: NSLayoutConstraint?
    var alertTopConstraint: NSLayoutConstraint?

    lazy var alertView: UIView = {
        let alertView = Util.createView()
        view.addSubview(alertView)
        return alertView
    }()

    lazy var alertLabel: UILabel = {
        let alertLabel = Util.createLabel(center: true)
        alertLabel.text = NSLocalizedString("No playlists yet.", comment: "")
        return alertLabel
    }()

    lazy var alertButton: UIButton = {
        let alertButton = Util.createButton(title: NSLocalizedString("Add New Playlist", comment: ""))
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
            guard let playlist = BackgroundPlayer.shared.playlist else { return }
            let modalController = PlaylistModalViewController(playlist: playlist)
            self?.present(modalController, animated: false, completion: nil)
        }

        view.addSubview(playlistBar)

        return playlistBar
    }()

    lazy var addItem: UIBarButtonItem = {
        Util.createBarButtonItem(iconCode: "library-add", target: self, action: #selector(addItemDidTap))
    }()

    lazy var editItem: UIBarButtonItem = {
        Util.createBarButtonItem(iconCode: "edit", target: self, action: #selector(editItemDidTap))
    }()

    lazy var doneItem: UIBarButtonItem = {
        Util.createBarButtonItem(iconCode: "close", target: self, action: #selector(doneItemDidTap))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Playlists", comment: "")

        view.backgroundColor = Color.darkGray

        setEditing(false, animated: false)

        buildLayout()

        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaylistBar),
                                               name: BackgroundPlayer.changeTrackNotification, object: nil)

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

        if editing && !Settings.shared.playlistsEdited {
            let alertController = UIAlertController(
                title: NSLocalizedString("Edit Playlists", comment: ""),
                message: NSLocalizedString("Please tap the cell to rename the playlist.", comment: ""),
                preferredStyle: .alert
            )
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            )
            present(alertController, animated: true, completion: nil)

            Settings.shared.playlistsEdited = true
        }
    }

    // MARK: - Actions

    @objc func addItemDidTap(sender: Any) {
        presentPlaylistAlert(title: NSLocalizedString("New Playlist", comment: ""), text: nil) { alertController in
            return UIAlertAction(
                title: NSLocalizedString("Add", comment: ""),
                style: .default,
                handler: { _ in
                    guard let text = alertController.textFields?.first?.text else { return }
                    let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    Playlist.create(name: trimmed)
                    self.refresh()
                }
            )
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

    func updatePlaylists() {
        playlists = Playlist.all
    }

    func refresh() {
        updatePlaylists()
        tableView.reloadData()
        updateAlertView()
        updateBarItems()
    }

    func updateAlertView() {
        if playlists.isEmpty {
            alertTopConstraint?.constant = 8.0
        } else {
            alertTopConstraint?.constant = -88.0
        }
    }

    func updateBarItems() {
        editItem.isEnabled = !playlists.isEmpty
    }

    func deselectRow(animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    func updateCells() {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                let playlist = playlists[indexPath.row]
                configureCell(cell, with: playlist)
            }
        }
    }

    @objc func updatePlaylistBar() {
        barBottomConstraint?.constant = BackgroundPlayer.shared.playlist == nil ? 60.0 : 0.0
    }

    func presentPlaylistAlert(title: String, text: String?, actionProvider: (UIAlertController) -> UIAlertAction) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Name", comment: "")
            textField.text = text
        }
        alertController.addAction(actionProvider(alertController))
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel,
                          handler: { [weak self] _ in self?.deselectRow(animated: true) })
        )
        present(alertController, animated: true, completion: nil)
    }
}

extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let playlist = playlists[indexPath.row]
        configureCell(cell, with: playlist)

        return cell
    }

    func configureCell(_ cell: UITableViewCell, with playlist: Playlist) {
        guard let cell = cell as? ItemCell else { return }

        cell.textLabel?.text = playlist.name
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = "\(playlist.tracks.count) \(NSLocalizedString("tracks", comment: ""))"

        cell.isPlaying = BackgroundPlayer.shared.playlist?.id == playlist.id
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]

        if tableView.isEditing {
            presentPlaylistAlert(title: NSLocalizedString("Edit Playlist", comment: ""),
                                 text: playlist.name) { [weak self] alertController in
                return UIAlertAction(
                    title: NSLocalizedString("Update", comment: ""),
                    style: .default,
                    handler: { _ in
                        guard let text = alertController.textFields?.first?.text else { return }
                        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        playlist.update(name: trimmed)
                        self?.updateCells()
                        self?.deselectRow(animated: true)
                    }
                )
            }
        } else {
            let tracksController = TracksViewController(playlist: playlist)
            navigationController?.pushViewController(tracksController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlist = playlists[indexPath.row]
            if BackgroundPlayer.shared.playlist?.id == playlist.id {
                BackgroundPlayer.shared.playlist = nil
            }
            playlist.destroy()
            updatePlaylists()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateAlertView()
                self?.updateBarItems()
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let playlist = playlists[sourceIndexPath.row]
        playlist.move(to: destinationIndexPath.row)
        updatePlaylists()
    }
}
