//
//  BirdCell.swift
//  Swiss-Birds
//
//  Created by Philipp on 13.10.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import SwiftUI

struct BirdCell: View {
    let bird: Species
    let searchText: String

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @State var image: UIImage = UIImage(named: "placeholder-headshot")!

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary, lineWidth: 0.5))
                .shadow(radius: 4)
                .accessibility(hidden: true)
                .overlay(
                    Group {
                        if favoritesManager.isFavorite(species: bird) {
                            Image(systemName: "star.fill")
                                .imageScale(.large)
                                .foregroundColor(.yellow)
                                .shadow(color: Color.black, radius: 1)
                                .offset(x: 4.0, y: -4.0)
                        }
                    },
                    alignment: .topTrailing
                )

            VStack(alignment: .leading) {
                Text(bird.name)

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
            .foregroundColor(.primary)
        }
        .accessibilityElement(children: .combine)
        .onReceive(state.getHeadShot(for: bird)) { (image) in
            if let image = image {
                self.image = image
            }
        }
    }
}

struct BirdCell_Previews: PreviewProvider {
    static var previews: some View {
        AppState_PreviewWrapper {
            ForEach(AppState.shared.allSpecies[0..<3]) { bird in
                BirdCell(bird: bird, searchText: "")
            }
        }
        .environmentObject(AppState.shared)
        .environmentObject(FavoritesManager.shared)
    }
}
