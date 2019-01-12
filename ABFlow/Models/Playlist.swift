//
//  Playlist.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/10.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import Foundation

class Playlist {
    var name = ""
    var tracks = [Track]()

    static var playlists = [Playlist]()

    static var all: [Playlist] {
        return playlists
    }

    static func load() {
        create(name: "test")
    }

    static func save() {

    }

    static func create(name: String) {
        let playlist = Playlist(name: name)
        Playlist.playlists.insert(playlist, at: 0)
    }

    init(name: String) {
        self.name = name
    }
}
