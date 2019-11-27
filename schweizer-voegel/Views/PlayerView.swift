//
//  PlayerView.swift
//  schweizer-voegel
//
//  Created by Philipp on 26.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import AVKit


class PlayerUIView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    
    func play(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        layer.addSublayer(playerLayer)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        playerLayer.frame = bounds
//    }
}

struct PlayerView: UIViewRepresentable {
    var assetName : String
    var playerUIView : PlayerUIView? {
        PlayerUIView(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        if playerUIView?.player == nil {
            playerUIView?.play(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        
        return playerUIView!
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(assetName:"10.mp3")
    }
}
