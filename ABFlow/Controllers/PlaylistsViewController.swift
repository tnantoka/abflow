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
    let itemSize = CGSize(width: 28.0, height: 28.0)

    var playlists = Playlist.all
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = Color.darkGray

        view.addSubview(tableView)

        return tableView
    }()

    lazy var addItem: UIBarButtonItem = {
        let addImage = UIImage(from: .materialIcon, code: "library.add", textColor: .black, backgroundColor: .clear, size: itemSize)
        let addItem = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(addItemDidTap))
        return addItem
    }()

    lazy var editItem: UIBarButtonItem = {
        let editImage = UIImage(from: .materialIcon, code: "edit", textColor: .black, backgroundColor: .clear, size: itemSize)
        let editItem = UIBarButtonItem(image: editImage, style: .plain, target: self, action: #selector(editItemDidTap))
        return editItem
    }()

    lazy var doneItem: UIBarButtonItem = {
        let doneImage = UIImage(from: .materialIcon, code: "close", textColor: .black, backgroundColor: .clear, size: itemSize)
        let doneItem = UIBarButtonItem(image: doneImage, style: .plain, target: self, action: #selector(doneItemDidTap))
        return doneItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Playlists", comment: "")

        view.backgroundColor = Color.darkGray

        setEditing(false, animated: false)

        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                let playlist = playlists[indexPath.row]
                configureCell(cell, with: playlist)
            }
        }

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            navigationItem.rightBarButtonItems = [doneItem]
        } else {
            navigationItem.rightBarButtonItems = [editItem, addItem]
        }

        tableView.setEditing(editing, animated: animated)
    }

    // MARK: - Actions

    @objc func addItemDidTap(sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("New Playlist", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Name", comment: "")
        }
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Add", comment: ""),
                style: .default,
                handler: { _ in
                    guard let text = alertController.textFields?.first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return }
                    guard !text.isEmpty else { return }
                    Playlist.create(name: text)
                    self.refresh()
                }
            )
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc func editItemDidTap(sender: Any) {
        setEditing(true, animated: true)
    }

    @objc func doneItemDidTap(sender: Any) {
        setEditing(false, animated: true)
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

    func updatePlaylists() {
        playlists = Playlist.all
    }

    func refresh() {
        updatePlaylists()
        tableView.reloadData()
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
        cell.textLabel?.text = playlist.name
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = "\(playlist.tracks.count) \(NSLocalizedString("tracks", comment: ""))"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        let tracksController = TracksViewController(playlist: playlist)
        navigationController?.pushViewController(tracksController, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlist = playlists[indexPath.row]
            playlist.destroy()
            updatePlaylists()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let playlist = playlists[sourceIndexPath.row]
        playlist.move(to: destinationIndexPath.row)
    }
}
