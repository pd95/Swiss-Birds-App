//
//  BirdDetail.swift
//  SwissBirds
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import AVKit

struct BirdDetail: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @EnvironmentObject var favoritesManager: FavoritesManager

    @ObservedObject var model: BirdDetailViewModel

    private let bird: Species

    private let birdDetails: VdsSpecieDetail
    private let characteristics: [Characteristic]

    @State var isPlaying: Bool = false
    @State var shareItem: ShareSheet.Item?

    init(model: BirdDetailViewModel) {
        self.model = model
        self.bird = model.bird
        self.birdDetails = model.details!

        let prioritySpeciesSymbol: String
        let prioritySpeciesText: String

        if let availablePrioInfo = birdDetails.prioritaetsartArtenfoerderung, !availablePrioInfo.isEmpty  {
            if availablePrioInfo == "1" {
                prioritySpeciesSymbol = "star.circle"
                prioritySpeciesText =  NSLocalizedString("Prioritaet_1", comment: "")
            } else {
                prioritySpeciesSymbol = ""
                prioritySpeciesText =  NSLocalizedString("Prioritaet_0", comment: "")
            }
        } else {
            prioritySpeciesSymbol = ""
            prioritySpeciesText = "-"
        }

        var characteristics: [Characteristic] = [
            .header(text: "Merkmale", children: [
                .text(text: birdDetails.merkmale)
            ]),
            .header(text: "Eigenschaften", children: [
                .text(label: FilterType.vogelgruppe.rawValue, text: bird.filterValue(.vogelgruppe)?.name, symbol: bird.filterSymbolName(.vogelgruppe)),
                .text(label: "Laenge_cm", text: birdDetails.laengeCM),
                .text(label: "Spannweite_cm", text: birdDetails.spannweiteCM),
                .text(label: "Gewicht_g", text: birdDetails.gewichtG),
                .separator(1),
                .text(label: "Nahrung", text: birdDetails.nahrung),
                .text(label: "Lebensraum", text: birdDetails.lebensraum),
                .text(label: "Zugverhalten", text: birdDetails.zugverhalten),
                .separator(2),
                .text(label: "Brutort", text: birdDetails.brutort),
                .text(label: "Brutdauer_Tage", text: birdDetails.brutdauerTage),
                .text(label: "Jahresbruten", text: birdDetails.jahresbruten),
                .text(label: "Gelegegroesse", text: birdDetails.gelegegroesse),
                .text(label: "Nestlingsdauer_Flugfaehigkeit_Tage", text: birdDetails.nestlingsdauerFlugfaehigkeitTage),
                .separator(3),
                .text(label: "Hoechstalter_CH", text: birdDetails.hoechstalterCH),
                .text(label: "Hoechstalter_EURING", text: birdDetails.hoechstalterEURING)
            ]),
            .header(text: "Status_in_CH", children: [
                .text(text: birdDetails.statusInCH)
            ]),
            .header(text: "Bestand", children: [
                .text(label: "Bestand", text: birdDetails.bestand),
                .text(label: "Rote_Liste_CH", text: birdDetails.roteListeCH, symbol: bird.filterSymbolName(.roteListe)),
                .text(label: "Prioritaetsart_Artenfoerderung", text: prioritySpeciesText, symbol: prioritySpeciesSymbol)
            ])
        ]

        // Collect list of names
        var allNames = [Characteristic]()
        allNames.append(.text(label: "Artname", text: bird.name))
        if let scientificName = birdDetails.familieWiss {
            allNames.append(.text(label: "Artname lat.", text: scientificName))
        }
        if primaryLanguage != "de" {
            allNames.append(.text(label: "Artname deu.", text: birdDetails.artnameDeu))
        }
        if primaryLanguage != "fr" {
            allNames.append(.text(label: "Artname frz.", text: birdDetails.artnameFrz ?? "-"))
        }
        if primaryLanguage != "it" {
            allNames.append(.text(label: "Artname ital.", text: birdDetails.artnameItal ?? "-"))
        }
        if primaryLanguage != "en" {
            allNames.append(.text(label: "Artname engl.", text: birdDetails.artnameEngl ?? "-"))
        }
        allNames.append(.text(label: "Artname rr.", text: birdDetails.artnameRr ?? "-"))
        allNames.append(.text(label: "Artname span.", text: birdDetails.artnameSpan ?? "-"))
        allNames.append(.text(label: "Artname holl.", text: birdDetails.artnameHoll ?? "-"))
        allNames.append(.text(label: "Familie wiss.", text: birdDetails.familieWiss ?? "-"))
        allNames.append(.text(label: "Synonyme", text: birdDetails.synonyme ?? "-"))
        allNames.append(.text(label: "Art-Nr.", text: String(birdDetails.artID)))

        characteristics.append(Characteristic.header(text: "Artnamen", children: allNames))
        self.characteristics = characteristics
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
                if sizeClass == .regular && !sizeCategory.isAccessibilityCategory {
                    HStack(alignment: .center) {
                        birdImages
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    birdImages
                        .frame(maxWidth: .infinity)
                }
                Text(birdDetails.infos!)
                    .font(.body)
                    .padding(.top)
                    .accessibility(identifier: "description")
                    .layoutPriority(1)

                CharacteristicsView(characteristics: characteristics)
            }
            .padding()
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(item: item)
        }
        .navigationBarTitle(Text(bird.name), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            favoriteButton
            shareButton
        })
        .task {
            await model.fetchData()
        }
        .onDisappear {
            stopSound()
        }
    }

    var birdImages: some View {
        Group {
            ForEach(model.imageDetails) { imageDetails in
                BirdImageView(image: imageDetails.image,
                              author: imageDetails.author,
                              description: imageDetails.description,
                              isLoading: imageDetails.isLoading)
                    .frame(maxWidth: imageDetails.image == nil ? 700 / 1.5 : imageDetails.image!.size.width / 1.5)
                    .accessibility(identifier: "bird_image_\(imageDetails.index+1)")
            }
        }
    }

    var favoriteButton: some View {
        let isFavorite = favoritesManager.isFavorite(species: bird)
        return Button(action: {
            favoritesManager.toggleFavorite(bird)
        }, label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .imageScale(.medium)
                .padding([.horizontal], 4)
                .padding([.vertical], 8)
                .foregroundColor( isFavorite ? .yellow : .accentColor)
        })
        .hoverEffect()
        .accessibility(label: Text(isFavorite ? "Favorit entfernen" : "Favorit setzen"))
    }

    var shareButton: some View {
        Button(action: shareDetails, label: {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.medium)
                .padding([.horizontal], 4)
                .padding([.vertical], 8)
        })
        .hoverEffect()
        .disabled(model.details == nil || shareItem != nil)
        .accessibility(label: Text("Teilen"))
    }

    private func shareDetails() {
        guard let artname = model.details?.artname,
              let alias = model.details?.alias
        else {
            return
        }
        let url = VdsAPI.homepage.appendingPathComponent(alias)
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
            } else {
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

    let bird: Species

    var body: some View {
        if model.bird.speciesId == bird.speciesId && model.details != nil {
            BirdDetail(model: model)
                .navigationBarTitle(Text(bird.name), displayMode: .inline)
        } else {
            ProgressView()
                .controlSize(.large)
                .navigationBarTitle(Text(bird.name), displayMode: .inline)
            .onAppear {
                model.setBird(bird)
            }
        }
    }

    var showAlert: Binding<Bool> {
        return Binding<Bool>(get: {model.error != nil}, set: { _ in model.error = nil })
    }
}

#Preview {
    let appState = AppState.shared
    AppState_PreviewWrapper {
        Group {
            if appState.allSpecies.count > 14 {
                let bird = appState.allSpecies[14]
                BirdDetailContainer(model: appState.currentBirdDetails, bird: bird)
                    .navigationBarTitle(Text(bird.name), displayMode: .inline)
            }
        }
        .id(appState.allSpecies.count)
    }
    .environmentObject(appState)
    .environmentObject(FavoritesManager.shared)
}

/// Audio player routines
private var audioPlayer: AVAudioPlayer?
