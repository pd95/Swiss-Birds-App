//
//  BirdDetail.swift
//  schweizer-voegel
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import AVKit


struct BirdDetail: View {
    var bird: Species
    
    @State var isPlaying : Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(bird.alternateName)
                        .font(.body)
                    Spacer()
                    Button(action: playVoice) {
                        Text("Stimme")
                        Image(systemName: isPlaying ? "stop.circle" : "play.circle")
                    }
                }
                Image("assets/\(bird.primaryPictureName).jpg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if bird.secondaryPictureName.count > 0 {
                    Image("assets/\(bird.secondaryPictureName).jpg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding()
        }
        .navigationBarTitle(Text(bird.name), displayMode: .inline)
        .onDisappear() {
            stopSound()
        }
    }
    
    func playVoice() {
        isPlaying.toggle()
        if isPlaying {
            playSound(nameOfAudioFileInAssetCatalog: "assets/\(bird.speciesId).mp3")
            isPlaying = alarmAudioPlayer?.isPlaying ?? false
        }
        else {
            stopSound()
        }
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BirdDetail(bird: allSpecies[3])
        }
    }
}

/// Audio player routines
private var alarmAudioPlayer: AVAudioPlayer?
func playSound(nameOfAudioFileInAssetCatalog: String) {
    if let sound = NSDataAsset(name: nameOfAudioFileInAssetCatalog) {
        do {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try! AVAudioSession.sharedInstance().setActive(true)
            try alarmAudioPlayer = AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)
            alarmAudioPlayer!.play()
        } catch {
            print("error initializing AVAudioPlayer")
        }
    }
}

func stopSound() {
    alarmAudioPlayer?.stop()
}
