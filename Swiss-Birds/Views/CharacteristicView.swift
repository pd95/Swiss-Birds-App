//
//  CharacteristicView.swift
//  Swiss-Birds
//
//  Created by Philipp on 03.11.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct CharacteristicView: View {

    let characteristic : Characteristic

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if characteristic.isHeader {
                Text(LocalizedStringKey(characteristic.text))
                    .font(.title)
                    .padding(.top)
            }
            else if characteristic.isSeparator {
                    Spacer()
            }
            else {
                if !characteristic.label.isEmpty {
                    Text(LocalizedStringKey(characteristic.label))
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 30.0)
                }
                if !characteristic.symbol.isEmpty {
                    SymbolView(symbolName: characteristic.symbol, pointSize: 16)
                        .accessibility(hidden: true)
                }
                Text(characteristic.text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(!characteristic.label.isEmpty ? TextAlignment.trailing : TextAlignment.leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibility(identifier: characteristic.identifier)
    }
}

struct CharacteristicsView : View {
    let characteristics : [Characteristic]

    var body: some View {
        ForEach(characteristics.filter {!$0.isEmpty}, id:\.self) { characteristic in
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


struct CharacteristicsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading) {
                CharacteristicsView(characteristics: Characteristic.example)
            }
            .padding()
        }
    }
}
