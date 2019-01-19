//
//  Settings.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/19.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import Foundation

class Settings {
    static let shared = Settings()

    struct Keys {
        static let playlistsEdited = "playlistsEdited"
        static let tracksEdited = "trackEditedsEdited"
    }

    static func reset() {
        shared.playlistsEdited = false
        shared.tracksEdited = false
    }

    var playlistsEdited: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.playlistsEdited)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.playlistsEdited)
            UserDefaults.standard.synchronize()
        }
    }

    var tracksEdited: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.tracksEdited)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.tracksEdited)
            UserDefaults.standard.synchronize()
        }
    }
}
