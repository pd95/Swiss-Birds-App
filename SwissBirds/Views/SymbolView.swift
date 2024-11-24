//
//  SymbolView.swift
//  SwissBirds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct SymbolView: View {

    @Environment(\.symbolRenderingMode) private var symbolRenderingMode

    private static let multiColorSymbols: Set<String> = [
        "filterentwicklungatlas-1",
        "filterentwicklungatlas-2",
        "filterentwicklungatlas-3",
        "filterentwicklungatlas-4",
        "filterentwicklungatlas-5",
        "filterrotelistech-1",
        "filterrotelistech-2",
        "filterrotelistech-3",
        "filterrotelistech-4",
        "filterrotelistech-5",
        "filterrotelistech-6"
    ]

    var symbolName: String

    var body: some View {
        Image(symbolName)
            .symbolRenderingMode(symbolRenderingMode ?? (Self.multiColorSymbols.contains(symbolName) ? .multicolor : .hierarchical))
            .imageScale(.large)
    }
}

#Preview {
    VStack {
        HStack {
            SymbolView(symbolName: "filterentwicklungatlas-1")
            Text(verbatim: "Bg")
            SymbolView(symbolName: "filterlebensraum-9")
            Text(verbatim: "By")
            SymbolView(symbolName: "filterlebensraum-10")
            Text(verbatim: "Hy")
        }
        .padding()

        Button(action: {}) {
            HStack {
                SymbolView(symbolName: "filterentwicklungatlas-1")
                Text(verbatim: "<-->")
                SymbolView(symbolName: "filterlebensraum-9")
            }
        }
        .buttonStyle(.bordered)
        .padding()

        HStack {
            SymbolView(symbolName: "filterentwicklungatlas-1")
            Text(verbatim: "Bg")
            SymbolView(symbolName: "filterlebensraum-9")
            Text(verbatim: "By")
            SymbolView(symbolName: "filterlebensraum-10")
                .symbolRenderingMode(.hierarchical)
            Text(verbatim: "Hy")
        }
        .padding()
        .background(Color(.systemBackground))
        .environment(\.colorScheme, .dark)
    }
    .font(.largeTitle)
    .imageScale(.large)
}
