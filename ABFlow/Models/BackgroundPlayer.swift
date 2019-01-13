//
//  BackgroundPlayer.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/13.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class BackgroundPlayer: NSObject {
    static let shared = BackgroundPlayer()

    var avPlayer: AVQueuePlayer?
    var playerItems = [AVPlayerItem]()

    var playlist: Playlist?

    private override init() {
        super.init()

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        prepareForRemoteControl()
    }

    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
    }

    func play(_ playlist: Playlist) {
        self.playlist = playlist
        playAll()
    }

    // MARK: - Actions

    @objc func playerItemDidEnd(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }

        if playerItem == playerItems.last {
            playAll()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard object is AVQueuePlayer else { return }
        guard keyPath == "currentItem" else { return }
        guard let currentItem = avPlayer?.currentItem else { return }
        guard let playlist = playlist else { return }

        if let index = playerItems.index(where: { $0 == currentItem }) {
            let track = playlist.tracks[index]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyAlbumTitle: playlist.name,
                MPMediaItemPropertyTitle: track.title,
                MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(currentItem.duration),
                MPNowPlayingInfoPropertyPlaybackRate: 1.0
            ]
        }
    }

    // MARK: - Utils

    private func playAll() {
        guard let playlist = playlist else { return }

        playerItems = playlist.tracks.map { $0.playerItem }

        avPlayer = AVQueuePlayer(items: playerItems)
        avPlayer?.addObserver(self, forKeyPath: "currentItem", options: [.initial], context: nil)

        avPlayer?.play()
    }

    private func prepareForRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()

        MPRemoteCommandCenter.shared().playCommand.addTarget { _ in
            print("play")
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
            print("pause")
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { _ in
            print("previousTrack")
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { _ in
            print("nextTrack")
            return MPRemoteCommandHandlerStatus.success
        }
    }
}
