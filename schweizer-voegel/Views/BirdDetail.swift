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

    private var birdDetails : SpeciesDetail
    
    private var characteristicsMap : [BirdCharacteristic]

    private var voiceData : NSDataAsset? {
        NSDataAsset(name: "assets/\(bird.speciesId).mp3")
    }

    @State var isPlaying : Bool = false
    
    init(bird: Species) {
        self.bird = bird
        birdDetails = load("\(bird.speciesId).json", as: [SpeciesDetail].self).first!
        characteristicsMap = [
            BirdCharacteristic.Header("Merkmale"),
            BirdCharacteristic(header: "", text: birdDetails.merkmale, symbol: nil),
            BirdCharacteristic.Header("Eigenschaften"),
            BirdCharacteristic(header: FilterType.vogelgruppe.rawValue, text: bird.filterValue(.vogelgruppe)?.name, symbol: bird.filterSymbolName(.vogelgruppe)),
            BirdCharacteristic(header: "Laenge_cm", text: birdDetails.laengeCM, symbol: nil),
            BirdCharacteristic(header: "Spannweite_cm", text: birdDetails.spannweiteCM, symbol: nil),
            BirdCharacteristic(header: "Gewicht_g", text: birdDetails.gewichtG, symbol: nil),
            BirdCharacteristic.Separator(),
            BirdCharacteristic(header: "Nahrung", text: birdDetails.nahrung, symbol: nil),
            BirdCharacteristic(header: "Lebensraum", text: birdDetails.lebensraum, symbol: nil),
            BirdCharacteristic(header: "Zugverhalten", text: birdDetails.zugverhalten, symbol: nil),
            BirdCharacteristic.Separator(),
            BirdCharacteristic(header: "Brutort", text: birdDetails.brutort, symbol: nil),
            BirdCharacteristic(header: "Brutdauer_Tage", text: birdDetails.brutdauerTage, symbol: nil),
            BirdCharacteristic(header: "Jahresbruten", text: birdDetails.jahresbruten, symbol: nil),
            BirdCharacteristic(header: "Gelegegroesse", text: birdDetails.gelegegroesse, symbol: nil),
            BirdCharacteristic(header: "Nestlingsdauer_Flugfaehigkeit_Tage", text: birdDetails.nestlingsdauerFlugfaehigkeitTage, symbol: nil),
            BirdCharacteristic.Separator(),
            BirdCharacteristic(header: "Hoechstalter_CH", text: birdDetails.hoechstalterCH, symbol: nil),
            BirdCharacteristic(header: "Hoechstalter_EURING", text: birdDetails.hoechstalterEURING, symbol: nil),
            BirdCharacteristic.Separator(),
            BirdCharacteristic.Header("Status_in_CH"),
            BirdCharacteristic(header: "", text: birdDetails.statusInCH, symbol: nil),
            BirdCharacteristic.Separator(),
            BirdCharacteristic.Header("Bestand"),
            BirdCharacteristic(header: "Bestand", text: birdDetails.bestand, symbol: nil),
            BirdCharacteristic(header: "Rote_Liste_CH", text: birdDetails.roteListeCH, symbol: bird.filterSymbolName(.roteListe)),
            BirdCharacteristic(header: "Prioritaetsart_Artenfoerderung", text: birdDetails.prioritaetsartArtenfoerderung, symbol: nil),
        ]
    }
    
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
                if birdDetails.autor0 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_0.jpg", autor: birdDetails.autor0!, description: birdDetails.bezeichnungDe0 ?? "")
                }
                if birdDetails.autor1 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_1.jpg", autor: birdDetails.autor1!, description: birdDetails.bezeichnungDe1 ?? "")
                }
                if birdDetails.autor2 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_2.jpg", autor: birdDetails.autor2!, description: birdDetails.bezeichnungDe2 ?? "")
                }
                Text(birdDetails.infos!)
                    .font(.body)
                    .padding(.top)
                ForEach(self.characteristicsMap) { characteristic in
                    BirdCharacteristicsRowView(characteristic:characteristic)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitle(Text(bird.name), displayMode: .inline)
        .onDisappear() {
            self.stopSound()
        }
    }
    
    private func playVoice() {
        if let data = voiceData?.data {
            isPlaying.toggle()
            if isPlaying {
                do {
                    try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    try! AVAudioSession.sharedInstance().setActive(true)
                    try audioPlayer = AVAudioPlayer(data: data, fileTypeHint: AVFileType.mp3.rawValue)
                    audioPlayer!.play()
                } catch {
                    print("error initializing AVAudioPlayer")
                }

                isPlaying = audioPlayer?.isPlaying ?? false
            }
            else {
                stopSound()
            }
        }
    }

    private func stopSound() {
        audioPlayer?.stop()
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
private var audioPlayer: AVAudioPlayer?


struct BirdCharacteristic : Identifiable {
    let id = UUID()

    let header : String
    let symbol : String?
    let text   : String?

    init(header: String, text: String?, symbol: String?) {
        self.header = header
        self.symbol = symbol
        if let text = text, text.count > 0 {
            self.text = text
        }
        else {
            self.text = nil
        }
    }
    
    static let titleHeader = "###"
    static let separatorHeader = "---"

    static func Separator() -> BirdCharacteristic {
        return BirdCharacteristic(header: separatorHeader, text: nil, symbol: nil)
    }

    static func Header(_ text: String) -> BirdCharacteristic {
        return BirdCharacteristic(header: titleHeader, text: text, symbol: nil)
    }
    
    var isTitle : Bool {
        return header == BirdCharacteristic.titleHeader
    }

    var isSeparator : Bool {
        return header == BirdCharacteristic.separatorHeader
    }

    var hasHeader : Bool {
        return !isTitle && !isSeparator && header.count > 0
    }
}


struct BirdCharacteristicsRowView: View {
    
    let characteristic : BirdCharacteristic
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if characteristic.isTitle {
                Text(LocalizedStringKey(characteristic.text!))
                    .font(.title)
                    .padding(.top)
            }
            else {
                if characteristic.isSeparator {
                    Spacer()
                }
                else {
                    if characteristic.text != nil {
                        if characteristic.hasHeader {
                            Text(LocalizedStringKey(characteristic.header))
                                .font(.headline)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 30.0)
                        }
                        if characteristic.symbol != nil {
                            SymbolView(symbolName: characteristic.symbol!, pointSize: 24)
                        }
                        Text(characteristic.text!)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(characteristic.hasHeader ? TextAlignment.trailing : TextAlignment.leading)
                    }
                    else {
                        EmptyView()
                    }
                }
            }
        }
    }
}
