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
    let isFavorite: Bool
    let searchText: String

    static private let placeholder = UIImage(named: "placeholder-headshot")!
    @State var image: UIImage?

    var body: some View {
        VStack {
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
            .accessibility(hidden: true)

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
        .onReceive(AppState.shared.getHeadShot(for: bird)) { (image) in
            if let image = image, self.image == nil {
                self.image = image
            }
        }
    }
}

struct BirdCell_Previews: PreviewProvider {
    static var previews: some View {
        AppState_PreviewWrapper {
            HStack {
                ForEach(Array(AppState.shared.allSpecies[0..<4].enumerated()), id: \.offset) { (index, bird) in
                    BirdCell(bird: bird, isFavorite: index >= 2, searchText: "")
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding(40)
        }
        .environmentObject(AppState.shared)
        .environmentObject(FavoritesManager.shared)
    }
}
