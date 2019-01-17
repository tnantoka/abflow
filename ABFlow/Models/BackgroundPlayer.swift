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

    var playlist: Playlist? {
        didSet {
            playAll()
        }
    }
    var currentItem: AVPlayerItem? {
        return avPlayer?.currentItem
    }
    var currentDuration: Float {
        guard let currentItem = avPlayer?.currentItem else { return 0.0 }
        return Float(CMTimeGetSeconds(currentItem.duration))
    }
    var currentTime: Float {
        guard let currentTime = avPlayer?.currentTime() else { return 0.0 }
        return Float(CMTimeGetSeconds(currentTime))
    }
    var currentTimeString: String {
        guard let avPlayer = avPlayer else { return "0:00:00" }
        return Util.formatDuration(CMTimeGetSeconds(avPlayer.currentTime()))
    }
    var isPlaying: Bool {
        guard let avPlayer = avPlayer else { return false }
        return avPlayer.timeControlStatus == .playing
    }
    var currentTrackTitle: String? {
        guard let currentItem = avPlayer?.currentItem else { return nil }
        guard let playlist = playlist else { return nil }

        if let index = playerItems.index(where: { $0 == currentItem }) {
            let track = playlist.tracks[index]
            return track.title
        }

        return nil
    }

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

        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] _ in
            self?.play()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self] _ in
            self?.prev()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self] _ in
            self?.next()
            return MPRemoteCommandHandlerStatus.success
        }
    }

    func play() {
        avPlayer?.play()
    }

    func pause() {
        avPlayer?.pause()
    }

    func prev() {
        guard let playlist = playlist else { return }
        guard let currentItem = avPlayer?.currentItem else { return }

        if let index = playerItems.index(where: { $0 == currentItem }) {
            let prevIndex = index > 0 ? index - 1 : playlist.tracks.count - 1
            play(index: prevIndex)
        }
    }

    func next() {
        guard let playlist = playlist else { return }
        guard let currentItem = avPlayer?.currentItem else { return }

        if let index = playerItems.index(where: { $0 == currentItem }) {
            let nextIndex = index < playlist.tracks.count - 1 ? index + 1 : 0
            play(index: nextIndex)
       }
    }

    func play(index: Int) {
        let isPlaying = self.isPlaying
        playAll()
        if !isPlaying {
            pause()
        }
        (0..<index).forEach { _ in avPlayer?.advanceToNextItem() }
    }
}
