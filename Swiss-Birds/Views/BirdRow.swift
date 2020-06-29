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

    @EnvironmentObject private var state : AppState
    @State var image: UIImage? = UIImage(named: "placeholder-headshot")
    
    func hasEntwicklungsAtlasSymbol() -> Bool {
        return bird.filterSymbolName(.entwicklungatlas).count > 0
    }
    
    var body: some View {
        HStack {
            if self.image != nil {
                Image(uiImage: self.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary, lineWidth: 0.5))
                    .shadow(radius: 4)
                    .accessibility(hidden: true)
            }
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
        .onReceive(state.getHeadShot(for: bird)) { (image) in
            self.image = image
        }
    }
}

struct BirdRow_Previews: PreviewProvider {
    static var previews: some View {
        List(AppState.shared.allSpecies[0..<3]) { bird in
            BirdRow(bird: bird)
        }
        .environmentObject(AppState.shared)
    }
}
