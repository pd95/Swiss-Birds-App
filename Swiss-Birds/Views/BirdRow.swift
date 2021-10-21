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
    let isFavorite: Bool
    let searchText: String
    let sortColumn: SortOptions.SortColumn

    @Environment(\.sizeCategory) var sizeCategory

    static private let placeholder = UIImage(named: "placeholder-headshot")!
    @State var image: UIImage?

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

                Image(uiImage: image ?? Self.placeholder)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(circle)

                circle.stroke(Color.primary, lineWidth: 0.5)
            }
            .overlay(
                GeometryReader { proxy in
                    if isFavorite {
                        let cellWidth = proxy.size.width
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: cellWidth*0.2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .foregroundColor(.yellow)
                            .shadow(color: Color.black, radius: 1)
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
                if sortColumn != .filterType(.entwicklungatlas) && hasEntwicklungsAtlasSymbol() {
                    SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
                        .accessibility(hidden: true)
                }
                if sortColumn != .filterType(.vogelgruppe) {
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
        .onReceive(AppState.shared.getHeadShot(for: bird)) { (image) in
            if let image = image {
                self.image = image
            }
        }
    }
}

struct BirdRow_Previews: PreviewProvider {
    static var previews: some View {
        AppState_PreviewWrapper {
            List(Array(AppState.shared.allSpecies[0..<3].enumerated()), id: \.offset) { (index, bird) in
                BirdRow(bird: bird, isFavorite: index >= 2, searchText: "", sortColumn: .speciesName)
            }
        }
        .environmentObject(AppState.shared)
        .environmentObject(FavoritesManager.shared)
    }
}
