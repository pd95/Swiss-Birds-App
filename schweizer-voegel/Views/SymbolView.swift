//
//  SymbolView.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct SymbolView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var symbolName = "filterentwicklungatlas-1"
    var pointSize : CGFloat = 24
    var color : Color? = nil
        
    var body: some View {
        Image(uiImage:
            UIImage(named: symbolName, in: nil, with: UIImage.SymbolConfiguration(pointSize: pointSize))
                ?? UIImage(systemName: "questionmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize))!
        )
            .renderingMode(colorScheme != .dark && color == nil ? Image.TemplateRenderingMode.original : Image.TemplateRenderingMode.template)
            .foregroundColor(colorScheme == .dark ? .secondary : color)
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SymbolView()
                .padding()
                .previewLayout(.fixed(width: 70, height: 70))

            SymbolView()
                .previewLayout(.fixed(width: 70, height: 70))
                .padding()
                .background(Color.black)
                .environment(\.colorScheme, .dark)
        }
    }
}
