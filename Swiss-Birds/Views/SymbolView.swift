//
//  SymbolView.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI


struct SymbolView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let symbolColors : [String:Color] = [
        "filterentwicklungatlas-1" : Color(#colorLiteral(red: 0.2941176471, green: 0.537254902, blue: 0.01568627451, alpha: 1)),
        "filterentwicklungatlas-2" : Color(#colorLiteral(red: 0.4823529412, green: 0.631372549, blue: 0.2980392157, alpha: 1)),
        "filterentwicklungatlas-3" : Color(#colorLiteral(red: 1, green: 0.8509803922, blue: 0.2980392157, alpha: 1)),
        "filterentwicklungatlas-4" : Color(#colorLiteral(red: 0.8901960784, green: 0.4039215686, blue: 0.06274509804, alpha: 1)),
        "filterentwicklungatlas-5" : Color(#colorLiteral(red: 0.8666666667, green: 0.2470588235, blue: 0.07843137255, alpha: 1)),
        "filterrotelistech-1" : Color(#colorLiteral(red: 0.4823529412, green: 0.631372549, blue: 0.2980392157, alpha: 1)),
        "filterrotelistech-2" : Color(#colorLiteral(red: 1, green: 0.8509803922, blue: 0.2980392157, alpha: 1)),
        "filterrotelistech-3" : Color(#colorLiteral(red: 0.937254902, green: 0.5490196078, blue: 0.1058823529, alpha: 1)),
        "filterrotelistech-4" : Color(#colorLiteral(red: 0.8901960784, green: 0.4039215686, blue: 0.06274509804, alpha: 1)),
        "filterrotelistech-5" : Color(#colorLiteral(red: 0.8666666667, green: 0.2470588235, blue: 0.07843137255, alpha: 1)),
        "filterrotelistech-6" : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    ]

    var symbolName : String
    var pointSize : CGFloat = 24
    var color : Color? = nil
        
    var body: some View {
        Image(uiImage:
            UIImage(named: symbolName, in: nil, with: UIImage.SymbolConfiguration(pointSize: pointSize))
                ?? UIImage(systemName: "questionmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize))!
        )
            .renderingMode(Image.TemplateRenderingMode.template)
            .foregroundColor(color ?? symbolColors[symbolName] ?? .primary)
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                SymbolView(symbolName: "filterentwicklungatlas-1")
                SymbolView(symbolName: "filterlebensraum-9")
                SymbolView(symbolName: "filterlebensraum-5", color: .green)
            }
            .padding()
            .previewLayout(.fixed(width: 100, height: 70))

            HStack {
                SymbolView(symbolName: "filterentwicklungatlas-1")
                SymbolView(symbolName: "filterlebensraum-9")
                SymbolView(symbolName: "filterlebensraum-5", color: .green)
            }
            .previewLayout(.fixed(width: 100, height: 70))
            .padding()
            .background(Color.black)
            .environment(\.colorScheme, .dark)
        }
    }
}
