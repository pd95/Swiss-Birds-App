//
//  BirdRow.swift
//  Swiss-Birds
//
//  Created by Philipp on 03.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct BirdRow: View {
    var bird: Species

    @Environment(\.sizeCategory) var sizeCategory
    @EnvironmentObject private var state : AppState
    @State var image: UIImage = UIImage(named: "placeholder-headshot")!
    
    func hasEntwicklungsAtlasSymbol() -> Bool {
        return !bird.filterSymbolName(.entwicklungatlas).isEmpty
    }

    var dynamicImageSize: CGFloat {
        UIFontMetrics.default.scaledValue(for: 40)
    }
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: dynamicImageSize, height: dynamicImageSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary, lineWidth: 0.5))
                .shadow(radius: 4)
                .accessibility(hidden: true)
                .overlay(
                    Group {
                        if state.isFavorite(species: bird) {
                            Image(systemName:  "star.fill")
                                .imageScale(.medium)
                                .foregroundColor(.yellow)
                                .shadow(color: Color.black, radius: 1)
                                .offset(x: 8.0, y: -7.0)
                        }
                    },
                    alignment: .topTrailing
                )

            Text(bird.name)
                .foregroundColor(.primary)
            Spacer()

            if !sizeCategory.isAccessibilityCategory {
                if state.sortOptions.column != .filterType(.entwicklungatlas) && hasEntwicklungsAtlasSymbol()  {
                    SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
                        .accessibility(hidden: true)
                }
                if state.sortOptions.column != .filterType(.vogelgruppe) {
                    SymbolView(symbolName: bird.filterSymbolName(.vogelgruppe), pointSize: 24, color: .secondary)
                        .accessibility(hidden: true)
                }
            }
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
        AppState_PreviewWrapper() {
            List(AppState.shared.allSpecies[0..<3]) { bird in
                BirdRow(bird: bird)
            }
        }
        .environmentObject(AppState.shared)
    }
}
