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
    
    func hasEntwicklungsAtlasSymbol() -> Bool {
        return bird.filterSymbolName(.entwicklungatlas).count > 0
    }
    
    var body: some View {
        HStack {
            Image("assets/\(bird.speciesId)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary, lineWidth: 0.5))
                .shadow(radius: 4)
                .accessibility(hidden: true)
            Text(bird.name)
                .foregroundColor(.primary)
            Spacer()
            if hasEntwicklungsAtlasSymbol() {
                SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
                    .accessibility(hidden: true)
            }
            SymbolView(symbolName: bird.filterSymbolName(.vogelgruppe), pointSize: 24, color: .secondary)
                .accessibility(hidden: true)
        }
//        .accessibilityElement(children: .contain)
    }
}

struct BirdRow_Previews: PreviewProvider {
    static let allSpecies: [Species] = loadSpeciesData()
    static var previews: some View {
        List {
            BirdRow(bird: allSpecies[40])
            BirdRow(bird: allSpecies[120])
            BirdRow(bird: allSpecies[304])
        }
    }
}
