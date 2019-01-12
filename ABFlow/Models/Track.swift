//
//  Track.swift
//  ABFlow
//
//  Created by Tatsuya Tobioka on 2019/01/12.
//  Copyright © 2019 tnantoka. All rights reserved.
//

import Foundation
import AVFoundation

class Track: Codable {
    let title: String
    let assetURL: URL
    var pointA: Double?
    var pointB: Double?

    init(title: String, assetURL: URL) {
        self.title = title
        self.assetURL = assetURL
    }

    var playerItem: AVPlayerItem {
        let asset = AVURLAsset(url: assetURL)

        guard let pointA = pointA, let pointB = pointB else {
            return AVPlayerItem(asset: asset)
        }

        let start = CMTime(seconds: pointA, preferredTimescale: asset.duration.timescale)
        let end = CMTime(seconds: pointB, preferredTimescale: asset.duration.timescale)
        let range = CMTimeRange(start: start, end: end)

        let composition = AVMutableComposition()
        try? composition.insertTimeRange(range, of: asset, at: .zero)

        let playerItem = AVPlayerItem(asset: composition)
        return playerItem
    }
}
