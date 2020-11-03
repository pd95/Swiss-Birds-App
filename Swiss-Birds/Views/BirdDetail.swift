//
//  BirdDetail.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import AVKit


struct BirdDetail: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var model: BirdDetailViewModel

    private let bird: Species

    private let birdDetails : VdsSpecieDetail
    private let characteristics : [Characteristic]

    @State var isPlaying : Bool = false
    @State var shareItem : ShareSheet.Item?

    init(model: BirdDetailViewModel) {
        self.model = model
        self.bird = model.bird
        self.birdDetails = model.details!
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

                    Button(action: playVoice) {
                        HStack {
                            Text("Stimme")
                            Image(systemName: isPlaying ? "stop.circle" : "play.circle")
                        }
                        .padding(4)
                    }
                    .disabled(model.voiceData == nil)
                    .hoverEffect()
                    .accessibility(identifier: "playVoiceButton")
                    .accessibility(label: Text("Stimme wiedergeben"))
                    .accessibility(value: Text(isPlaying ? "Spielt" : "Pausiert"))
                }
                if sizeClass == .regular && !sizeCategory.isAccessibilityCategory  {
                    HStack(alignment: .center) {
                        birdImages
                    }
                    .frame(maxWidth: .infinity)
                }
                else {
                    birdImages
                        .frame(maxWidth: .infinity)
                }
                Text(birdDetails.infos!)
                    .font(.body)
                    .padding(.top)
                    .accessibility(identifier: "description")

                CharacteristicsView(characteristics: characteristics)
            }
            .padding()
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(item: item)
        }
        .navigationBarTitle(Text(bird.name), displayMode: .inline)
        .navigationBarItems(trailing: shareButton)
        .onDisappear() {
            stopSound()
        }
    }

    var birdImages: some View {
        Group {
            ForEach(model.imageDetails) { imageDetails in
                BirdImageView(image: imageDetails.image,
                              author: imageDetails.author,
                              description: imageDetails.description)
                    .frame(maxWidth: imageDetails.image == nil ? 700 / 1.5 : imageDetails.image!.size.width / 1.5)
                    .accessibility(identifier: "bird_image_\(imageDetails.index+1)")
            }
        }
    }

    var shareButton: some View {
        Button(action: shareDetails, label: {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .padding([.horizontal], 4)
                .padding([.vertical], 8)
        })
        .hoverEffect()
        .disabled(model.details == nil || shareItem != nil)
        .accessibility(label: Text("Teilen"))
    }

    private func shareDetails() {
        guard let artname = model.details?.artname else { return }

        // Transform species name into URL compatible way: get rid of cases, diacritics and replace spaces with dashes
        let name = artname
            .lowercased()
            .replacingOccurrences(of: "ä", with: "ae")
            .replacingOccurrences(of: "ö", with: "oe")
            .replacingOccurrences(of: "ü", with: "ue")
            .folding(options: [.diacriticInsensitive], locale: nil)
            .replacingOccurrences(of: " ", with: "-")

        // Language dependent entry path
        let path: String
        switch language {
            case "de":
                path = "de/voegel/voegel-der-schweiz/\(name)"
            case "fr":
                path = "fr/oiseaux/les-oiseaux-de-suisse/\(name)"
            case "it":
                path = "it/uccelli/uccelli-della-svizzera/\(name)"
            case "en":
                path = "en/birds/birds-of-switzerland/\(name)"
            default:
                path = language
        }

        let url = VdsAPI.base.appendingPathComponent(path)
        shareItem = ShareSheet.Item(subject: artname, activityItems: [url])
    }

    private func playVoice() {
        if let data = model.voiceData {
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

struct BirdDetailContainer: View {

    @ObservedObject var model: BirdDetailViewModel

    init(bird: Species) {
        model = BirdDetailViewModel(bird: bird)
    }

    var body: some View {
        Group {
            if model.details != nil {
                BirdDetail(model: model)
            }
            else {
                ActivityIndicatorView(style: .large)
                .onAppear {
                    model.fetchData()
                }
            }
        }
        .navigationBarTitle(Text(model.bird.name), displayMode: .inline)
    }

    var showAlert: Binding<Bool> {
        return Binding<Bool>(get: {model.error != nil}, set: { _ in model.error = nil })
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static let appState = AppState.shared
    static var bird = {
        AppState.shared.allSpecies[14]
    }()
    static var previews: some View {
        NavigationView {
            List {
                Text(bird.name)
            }
            BirdDetailContainer(bird: bird)
        }
        .environmentObject(appState)
        .previewLayout(.fixed(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width))
    }
}

/// Audio player routines
private var audioPlayer: AVAudioPlayer?
