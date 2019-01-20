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
        static let tracksAdded = "tracksAdded"
    }

    static func reset() {
        shared.playlistsEdited = false
        shared.tracksEdited = false
        shared.tracksAdded = false
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

    var tracksAdded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.tracksAdded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.tracksAdded)
            UserDefaults.standard.synchronize()
        }
    }
}
