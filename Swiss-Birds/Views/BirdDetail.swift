//
//  BirdDetail.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import AVKit


struct BirdImageView: View {
    var asset : String
    var author : String
    var description : String
    
    var body: some View {
        VStack {
            Image(asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack {
                Text(description)
                Spacer()
                Text("© \(author)")
            }
            .padding([.leading, .bottom, .trailing], 8)
            .font(.caption)
        }
        .background(Color(.systemGray5))
        .cornerRadius(5)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Vogelbild zeigt \(description)"))
    }
}


struct BirdDetail: View {
    var bird: Species

    private var birdDetails : SpeciesDetail
    
    private var characteristics : [Characteristic]

    private var voiceData : NSDataAsset? {
        NSDataAsset(name: "assets/\(bird.speciesId).mp3")
    }

    @State var isPlaying : Bool = false
    
    init(bird: Species) {
        self.bird = bird
        birdDetails = load("\(bird.speciesId).json", as: [SpeciesDetail].self).first!
        characteristics = [
            .header(text: "Merkmale", children: [
                .text(text: birdDetails.merkmale)
            ]),
            .header(text: "Eigenschaften", children: [
                .text(label: FilterType.vogelgruppe.rawValue, text: bird.filterValue(.vogelgruppe)?.name, symbol: bird.filterSymbolName(.vogelgruppe)),
                .text(label: "Laenge_cm", text: birdDetails.laengeCM),
                .text(label: "Spannweite_cm", text: birdDetails.spannweiteCM),
                .text(label: "Gewicht_g", text: birdDetails.gewichtG),
                .separator,
                .text(label: "Nahrung", text: birdDetails.nahrung),
                .text(label: "Lebensraum", text: birdDetails.lebensraum),
                .text(label: "Zugverhalten", text: birdDetails.zugverhalten),
                .separator,
                .text(label: "Brutort", text: birdDetails.brutort),
                .text(label: "Brutdauer_Tage", text: birdDetails.brutdauerTage),
                .text(label: "Jahresbruten", text: birdDetails.jahresbruten),
                .text(label: "Gelegegroesse", text: birdDetails.gelegegroesse),
                .text(label: "Nestlingsdauer_Flugfaehigkeit_Tage", text: birdDetails.nestlingsdauerFlugfaehigkeitTage),
                .separator,
                .text(label: "Hoechstalter_CH", text: birdDetails.hoechstalterCH),
                .text(label: "Hoechstalter_EURING", text: birdDetails.hoechstalterEURING),
            ]),
            .header(text: "Status_in_CH", children: [
                .text(text: birdDetails.statusInCH)
            ]),
            .header(text: "Bestand", children: [
                .text(label: "Bestand", text: birdDetails.bestand),
                .text(label: "Rote_Liste_CH", text: birdDetails.roteListeCH, symbol: bird.filterSymbolName(.roteListe)),
                .text(label: "Prioritaetsart_Artenfoerderung", text: birdDetails.prioritaetsartArtenfoerderung),
            ]),
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    if !bird.alternateName.isEmpty {
                        Text(bird.alternateName)
                            .font(.body)
                            .accessibility(label: Text("Alternativname"))
                            .accessibility(value: Text(bird.alternateName))
                            .accessibility(identifier: "alternateName")
                    }
                    Spacer()
                    if voiceData != nil {
                        Button(action: playVoice) {
                            Text("Stimme")
                            Image(systemName: isPlaying ? "stop.circle" : "play.circle")
                        }
                        .accessibility(identifier: "playVoiceButton")
                        .accessibility(label: Text("Stimme wiedergeben"))
                        .accessibility(value: Text(isPlaying ? "Spielt" : "Pausiert"))
                    }
                }
                if birdDetails.autor0 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_0.jpg", author: birdDetails.autor0!, description: birdDetails.bezeichnungDe0 ?? "")
                        .accessibility(identifier: "bird_image_1")
                }
                if birdDetails.autor1 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_1.jpg", author: birdDetails.autor1!, description: birdDetails.bezeichnungDe1 ?? "")
                    .accessibility(identifier: "bird_image_2")
                }
                if birdDetails.autor2 != "" {
                    BirdImageView(asset: "assets/\(bird.speciesId)_2.jpg", author: birdDetails.autor2!, description: birdDetails.bezeichnungDe2 ?? "")
                    .accessibility(identifier: "bird_image_3")
                }
                Text(birdDetails.infos!)
                    .font(.body)
                    .padding(.top)
                    .accessibility(identifier: "description")

                CharacteristicsView(characteristics: characteristics)
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
    static let allSpecies: [Species] = loadSpeciesData()
    static var previews: some View {
        NavigationView {
            BirdDetail(bird: allSpecies[14])
        }
    }
}

/// Audio player routines
private var audioPlayer: AVAudioPlayer?


enum Characteristic : Hashable {
    
    indirect case header(text: String, children: [Characteristic])
    case separator
    case text(label: String = "", text: String?, symbol: String = "")

    var isEmpty: Bool {
        switch self {
        case let .header(_, children):
            let r = children.reduce(true) {$0 && $1.isEmpty}
            return r
        case let .text(_, text, _):
            let r = text == nil || text!.isEmpty
            return r
        default:
            return false
        }
    }
    
    var isHeader: Bool {
        switch self {
        case .header:
            return true
        default:
            return false
        }
    }
    
    var isSeparator: Bool {
        switch self {
        case .separator:
            return true
        default:
            return false
        }
    }
    
    var text: String {
        switch self {
        case let .header(text, _):
            return text
        case let .text(_, text, _):
            return text!
        default:
            return ""
        }
    }
    
    var label: String {
        switch self {
        case let .text(label, _, _):
            return label
        default:
            return ""
        }
    }

    var symbol: String {
        switch self {
        case let .text(_, _, symbol):
            return symbol
        default:
            return ""
        }
    }

    var children: [Characteristic] {
        switch self {
        case let .header(_, children):
            return children
        default:
            fatalError("This shouldn't happen!")
        }
    }
}

struct CharacteristicView: View {

    let characteristic : Characteristic

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if characteristic.isHeader {
                Text(LocalizedStringKey(characteristic.text))
                    .font(.title)
                    .padding(.top)
            }
            else {
                if characteristic.isSeparator {
                    Spacer()
                }
                else {
                    if characteristic.label != "" {
                        Text(LocalizedStringKey(characteristic.label))
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .accessibility(identifier: characteristic.label)
                            Spacer(minLength: 30.0)
                    }
                    if characteristic.symbol != "" {
                        SymbolView(symbolName: characteristic.symbol, pointSize: 18)
                        .accessibility(hidden: true)
                    }
                    Text(characteristic.text)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(characteristic.label != "" ? TextAlignment.trailing : TextAlignment.leading)
                        .accessibility(identifier: "\(characteristic.label)_value")
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct CharacteristicsView : View {
    let characteristics : [Characteristic]
    
    var body: some View {
        ForEach(self.characteristics.filter {!$0.isEmpty}, id:\.self) { characteristic in
            Group {
                CharacteristicView(characteristic: characteristic)
                if characteristic.isHeader {
                    CharacteristicsView(characteristics: characteristic.children)
                        .padding(.top, 10.0)
                }
            }
        }
    }
}
