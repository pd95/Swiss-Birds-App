//
//  BirdRow.swift
//  Swiss-Birds
//
//  Created by Philipp on 03.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct BirdRow: View {
    let bird: Species
    let searchText: String

    @Environment(\.sizeCategory) var sizeCategory
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @State var image: UIImage = UIImage(named: "placeholder-headshot")!

    func hasEntwicklungsAtlasSymbol() -> Bool {
        return !bird.filterSymbolName(.entwicklungatlas).isEmpty
    }

    var dynamicImageSize: CGFloat {
        UIFontMetrics.default.scaledValue(for: 40)
    }

    var body: some View {
        HStack {
            ZStack {
                let circle = Circle()
                circle.shadow(radius: 5)

                Image(uiImage: image)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(circle)

                circle.stroke(Color.primary, lineWidth: 0.5)
            }
            .overlay(
                Group {
                    if favoritesManager.isFavorite(species: bird) {
                        Image(systemName: "star.fill")
                            .imageScale(.medium)
                            .foregroundColor(.yellow)
                            .shadow(color: Color.black, radius: 1)
                            .offset(x: 8.0, y: -7.0)
                    }
                },
                alignment: .topTrailing
            )
            .frame(width: dynamicImageSize, height: dynamicImageSize)
            .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text(bird.name)
                    .foregroundColor(.primary)

                if searchText.isEmpty == false {
                    let nameMatches = bird.allNameMatches(searchText)
                    ForEach(preferredLanguageOrder, id: \.self) { language in
                        let match = nameMatches[language, default: (nil, nil)]
                        if match.name != nil || match.alternateName != nil {
                            Group {
                                if language == primaryLanguage {
                                    if let alternateName = match.alternateName {
                                        Text(alternateName)
                                            .font(.footnote)
                                    }
                                } else {
                                    Text("\(language): ")
                                        .font(.footnote.italic())
                                    + Text("\(match.name ?? "") \(match.alternateName ?? "")".trimmingCharacters(in: .whitespaces))
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
            }
            .transition(.opacity)
            .animation(.easeIn(duration: 0.2))
            Spacer()

            if !sizeCategory.isAccessibilityCategory {
                if state.sortOptions.column != .filterType(.entwicklungatlas) && hasEntwicklungsAtlasSymbol() {
                    SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
                        .accessibility(hidden: true)
                }
                if state.sortOptions.column != .filterType(.vogelgruppe) {
                    SymbolView(symbolName: bird.filterSymbolName(.vogelgruppe), pointSize: 24, color: .secondary)
                        .accessibility(hidden: true)
                }
            }

            Image(systemName: "chevron.right")
                .imageScale(.small)
                .font(.headline)
                .foregroundColor(Color(.tertiaryLabel))
        }
        .accessibilityElement(children: .combine)
        .onReceive(state.getHeadShot(for: bird)) { (image) in
            if let image = image {
                self.image = image
            }
        }
    }
}

struct BirdRow_Previews: PreviewProvider {
    static var previews: some View {
        AppState_PreviewWrapper {
            List(AppState.shared.allSpecies[0..<3]) { bird in
                BirdRow(bird: bird, searchText: "")
            }
        }
        .environmentObject(AppState.shared)
        .environmentObject(FavoritesManager.shared)
    }
}
