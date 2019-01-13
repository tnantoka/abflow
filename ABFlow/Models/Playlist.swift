//
//  Playlist.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/10.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import Foundation

class Playlist: Codable {
    let id = UUID().uuidString
    private(set) var name = ""
    private(set) var tracks = [Track]()

    static var playlists = [Playlist]()

    static var all: [Playlist] {
        return playlists
    }
    static var jsonURL: URL {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docsURL.appendingPathComponent("playlists.json")
    }

    static func load() {
        guard let data = try? Data(contentsOf: jsonURL) else { return }
        guard let playlists = try? JSONDecoder().decode([Playlist].self, from: data) else { return }
        self.playlists = playlists
    }

    static func save() {
        guard let data = try? JSONEncoder().encode(playlists) else { return }
        try? data.write(to: jsonURL)
    }

    static func create(name: String) {
        let playlist = Playlist(name: name)
        Playlist.playlists.insert(playlist, at: 0)

        save()
    }

    static func hoge() {
    }

    init(name: String) {
        self.name = name
    }

    func update(name: String) {
        self.name = name

        Playlist.save()
    }

    func destroy() {
        Playlist.playlists.removeAll { $0.id == id }

        Playlist.save()
    }

    func move(to i: Int) {
        Playlist.playlists.removeAll { $0.id == id }
        Playlist.playlists.insert(self, at: i)

        Playlist.save()
    }

    // MARK: - Tracks

    func appendTracks(_ tracks: [Track]) {
        self.tracks.append(contentsOf: tracks)

        Playlist.save()
    }

    func destroyTrack(_ track: Track) {
        tracks.removeAll { $0.id == track.id }

        Playlist.save()
    }

    func moveTrack(_ track: Track, to i: Int) {
        tracks.removeAll { $0.id == track.id }
        tracks.insert(track, at: i)

        Playlist.save()
    }
}
