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
                        Text("Stimme")
                        Image(systemName: isPlaying ? "stop.circle" : "play.circle")
                    }
                    .disabled(model.voiceData == nil)
                    .accessibility(identifier: "playVoiceButton")
                    .accessibility(label: Text("Stimme wiedergeben"))
                    .accessibility(value: Text(isPlaying ? "Spielt" : "Pausiert"))
                }
                if sizeClass == .regular {
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
        .navigationBarItems(trailing:
            Button(action: self.shareDetails, label: {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
                    .padding()
                    .accessibility(label: Text("Teilen"))
            })
            .disabled(self.model.details == nil)
        )
        .onDisappear() {
            self.stopSound()
        }
    }

    var birdImages: some View {
        Group {
            ForEach(model.imageDetails) { imageDetails in
                BirdImageView(image: imageDetails.image,
                              author: imageDetails.author,
                              description: imageDetails.description)
                    .frame(maxWidth: imageDetails.image == nil ? .infinity : imageDetails.image!.size.width / 1.5)
                    .accessibility(identifier: "bird_image_\(imageDetails.index+1)")
                    // Workaround scrollview issue: onLongPressGesture conflicts with ScrollView, so we add a tap gesture recognizer!?
                    .onTapGesture { }
                    .onLongPressGesture {
                        self.shareImageDetail(imageDetails)
                    }
            }
        }
    }

    func shareDetails() {
        shareItem = .init(subject: self.model.details?.artname ?? "", activityItems: [VdsAPI.base.appendingPathComponent(self.model.details?.uri ?? "")])
    }

    func shareImageDetail(_ imageDetails: BirdDetailViewModel.ImageDetails) {
        if let image = imageDetails.image, let name = model.details?.artname {
            shareItem = .init(subject:
                "\(name): \(imageDetails.description)",
                activityItems: [image])
        }
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
            if self.model.details != nil {
                BirdDetail(model: model)
            }
            else {
                ActivityIndicatorView(style: .large)
                .onAppear {
                    self.model.fetchData()
                }
            }
        }
        .alert(isPresented: showAlert, content: { () -> Alert in
            Alert(title: Text("An error occured"),
                  message: Text(model.error!.localizedDescription),
                  dismissButton: .default(Text("Dismiss")))
        })
        .navigationBarTitle(Text(model.bird.name), displayMode: .inline)
    }

    var showAlert: Binding<Bool> {
        return Binding<Bool>(get: {self.model.error != nil}, set: { _ in self.model.error = nil })
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static let appState = AppState.shared
    static var previews: some View {
        NavigationView {
            BirdDetailContainer(bird: appState.allSpecies[14])
        }
        .environmentObject(appState)
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
