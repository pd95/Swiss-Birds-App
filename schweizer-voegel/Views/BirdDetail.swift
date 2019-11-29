//
//  BirdDetail.swift
//  schweizer-voegel
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import AVKit


struct BirdImageView: View {
    var asset : String
    var autor : String
    var description : String
    
    var body: some View {
        VStack {
            Image(asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack {
                Text(description)
                Spacer()
                Text("© \(autor)")
            }
            .padding([.leading, .bottom, .trailing], 8)
            .font(.caption)
        }
        .background(Color(.systemGray5))
        .cornerRadius(5)
    }
}


struct BirdDetail: View {
    var bird: Species

    private var birdDetails : SpeciesDetail? {
        load("\(bird.speciesId).json", as: [SpeciesDetail].self).first
    }

    private var voiceData : NSDataAsset? {
        NSDataAsset(name: "assets/\(bird.speciesId).mp3")
    }

    @State var isPlaying : Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(bird.alternateName)
                        .font(.body)
                    Spacer()
                    if voiceData != nil {
                        Button(action: playVoice) {
                            Text("Stimme")
                            Image(systemName: isPlaying ? "stop.circle" : "play.circle")
                        }
                    }
                }
                if birdDetails?.autor0 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_0.jpg", autor: birdDetails!.autor0!, description: birdDetails!.bezeichnungDe0 ?? "")
                }
                if birdDetails?.autor1 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_1.jpg", autor: birdDetails!.autor1!, description: birdDetails!.bezeichnungDe1 ?? "")
                }
                if birdDetails?.autor2 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_2.jpg", autor: birdDetails!.autor2!, description: birdDetails!.bezeichnungDe2 ?? "")
                }
                Text(birdDetails!.infos!)
                    .font(.body)
                    .padding(.top)
                
            }
            .padding()
        }
        .navigationBarTitle(Text(bird.name), displayMode: .inline)
        .onDisappear() {
            self.stopSound()
        }
    }
    
    func playVoice() {
        if let data = voiceData?.data {
            isPlaying.toggle()
            if isPlaying {
                do {
                    try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    try! AVAudioSession.sharedInstance().setActive(true)
                    try alarmAudioPlayer = AVAudioPlayer(data: data, fileTypeHint: AVFileType.mp3.rawValue)
                    alarmAudioPlayer!.play()
                } catch {
                    print("error initializing AVAudioPlayer")
                }

                isPlaying = alarmAudioPlayer?.isPlaying ?? false
            }
            else {
                stopSound()
            }
        }
    }

    func stopSound() {
        alarmAudioPlayer?.stop()
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BirdDetail(bird: allSpecies[14])
        }
//        .environment(\.colorScheme, .dark)
    }
}

/// Audio player routines
private var alarmAudioPlayer: AVAudioPlayer?

