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

    static let changePlaylistNotification = Notification.Name("changePlaylistNotification")
    static let changeTrackNotification = Notification.Name("changeTrackNotification")

    static let speeds: [Float] = [0.75, 1.0, 1.5, 2.0]
    enum RepeatMode {
        case all
        case one
    }

    var avPlayer: AVQueuePlayer?
    var playerItems = [AVPlayerItem]()
    var allPlayerItems = [AVPlayerItem]()
    var playlist: Playlist? {
        didSet {
            stop()
            playAll()
            NotificationCenter.default.post(name: BackgroundPlayer.changePlaylistNotification, object: nil)
        }
    }
    var track: Track? {
        didSet {
            NotificationCenter.default.post(name: BackgroundPlayer.changeTrackNotification, object: nil)
        }
    }

    var speed: Float = 1.0 {
        didSet {
            avPlayer?.rate = speed
        }
    }
    var repeatMode = RepeatMode.all {
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
        return track?.title
    }

    var observeCurrentItem: NSKeyValueObservation?

    private override init() {
        super.init()

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidEnd),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)

        prepareForRemoteControl()
    }

    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
    }

    // MARK: - Actions

    @objc func playerItemDidEnd(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }

        if playerItem == playerItems.last {
            replayAll()
        }
    }

    // MARK: - Utils

    private func playAll() {
        guard let playlist = playlist else { return }
        guard !playlist.tracks.isEmpty else { return }

        let currentIndex = allPlayerItems.index { $0 == currentItem } ?? 0
        allPlayerItems = playlist.tracks.map { $0.playerItem }

        if repeatMode == .one {
            playerItems = [allPlayerItems[currentIndex]]
        } else {
            playerItems = allPlayerItems
        }

        avPlayer = AVQueuePlayer(items: playerItems)
        observePlayer()

        play()
    }

    private func replayAll() {
        guard let playlist = playlist else { return }
        guard !playlist.tracks.isEmpty else { return }

        let currentIndex = allPlayerItems.index { $0 == playerItems.last } ?? 0
        allPlayerItems = playlist.tracks.map { $0.playerItem }

        if repeatMode == .one {
            playerItems = [allPlayerItems[currentIndex]]
        } else {
            playerItems = allPlayerItems
        }

        avPlayer = AVQueuePlayer(items: playerItems)
        observePlayer()

        play()
    }

    private func observePlayer() {
        observeCurrentItem = avPlayer?.observe(\.currentItem, options: [.initial], changeHandler: { [weak self] _, _ in
            guard let currentItem = self?.avPlayer?.currentItem else { return }
            guard let playlist = self?.playlist else { return }

            if let index = self?.allPlayerItems.index(where: { $0 == currentItem }) {
                let track = playlist.tracks[index]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                    MPMediaItemPropertyAlbumTitle: playlist.name,
                    MPMediaItemPropertyTitle: track.title,
                    MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(currentItem.duration),
                    MPNowPlayingInfoPropertyPlaybackRate: 1.0
                ]
                self?.track = track
            }
        })
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
        avPlayer?.rate = speed
    }

    func pause() {
        avPlayer?.pause()
    }

    func stop() {
        pause()
        track = nil
        avPlayer = nil
        allPlayerItems = []
        playerItems = []
    }

    func prev() {
        guard let currentItem = avPlayer?.currentItem else { return }

        if let index = allPlayerItems.index(where: { $0 == currentItem }) {
            let prevIndex = index > 0 ? index - 1 : playerItems.count - 1
            play(index: prevIndex)
        }
    }

    func next() {
        guard let currentItem = avPlayer?.currentItem else { return }

        if let index = allPlayerItems.index(where: { $0 == currentItem }) {
            let nextIndex = index < playerItems.count - 1 ? index + 1 : 0
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

    func changeSpeed() {
        guard let index = BackgroundPlayer.speeds.index(where: { $0 == speed }) else { return }

        let nextIndex = index < BackgroundPlayer.speeds.count - 1 ? index + 1 : 0
        speed = BackgroundPlayer.speeds[nextIndex]
    }

    func changeRepeatMode() {
        repeatMode = repeatMode == .all ? .one : .all
    }
}
