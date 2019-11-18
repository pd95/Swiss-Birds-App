//
//  SymbolView.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct SymbolView: View {
    var symbolName = "filterentwicklungatlas-1"
    var pointSize : CGFloat = 24
    var color : Color? = nil
        
    var body: some View {
        Image(uiImage:
            UIImage(named: symbolName, in: nil, with: UIImage.SymbolConfiguration(pointSize: pointSize))
                ?? UIImage(systemName: "questionmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize))!
        )
            .renderingMode( color == nil ? Image.TemplateRenderingMode.original : Image.TemplateRenderingMode.template)
            .foregroundColor(color)
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView()
    }
}
