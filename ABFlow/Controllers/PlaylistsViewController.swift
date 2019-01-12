//
//  PlaylistsViewController.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/10.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit

class PlaylistsViewController: UIViewController {
    let cellIdentifier = "PlaylistCell"

    var playlists = Playlist.all
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        view.addSubview(tableView)

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Playlists", comment: "")

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemDidTap))
        navigationItem.rightBarButtonItem = addItem

        buildLayout()
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

    // MARK: - Utils

    func buildLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0)
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
        cell.textLabel?.text = playlist.name
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        let tracksController = TracksViewController(playlist: playlist)
        navigationController?.pushViewController(tracksController, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlist = playlists[indexPath.row]
            playlist.destroy()
            updatePlaylists()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
