//
//  SymbolView.swift
//  SwissBirds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct SymbolView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private static var symbolImageCache = [String: (pointSize: CGFloat, image: UIImage)]()

    private static func symbol(for symbolName: String, with pointSize: CGFloat) -> UIImage {
        if let cachedImage = symbolImageCache[symbolName],
           cachedImage.pointSize == pointSize {
            return cachedImage.image
        }
        let symbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: UIFontMetrics.default.scaledValue(for: pointSize)
        )
        let image = UIImage(named: symbolName, in: nil, with: symbolConfiguration) ?? UIImage(systemName: symbolName, withConfiguration: symbolConfiguration) ?? UIImage()
        symbolImageCache[symbolName] = (pointSize, image)
        return image
    }

    private static let symbolColors: [String: Color] = [
        "filterentwicklungatlas-1": Color(#colorLiteral(red: 0.2941176471, green: 0.537254902, blue: 0.01568627451, alpha: 1)),
        "filterentwicklungatlas-2": Color(#colorLiteral(red: 0.4823529412, green: 0.631372549, blue: 0.2980392157, alpha: 1)),
        "filterentwicklungatlas-3": Color(#colorLiteral(red: 1, green: 0.8509803922, blue: 0.2980392157, alpha: 1)),
        "filterentwicklungatlas-4": Color(#colorLiteral(red: 0.8901960784, green: 0.4039215686, blue: 0.06274509804, alpha: 1)),
        "filterentwicklungatlas-5": Color(#colorLiteral(red: 0.8666666667, green: 0.2470588235, blue: 0.07843137255, alpha: 1)),
        "filterrotelistech-1": Color(#colorLiteral(red: 0.4823529412, green: 0.631372549, blue: 0.2980392157, alpha: 1)),
        "filterrotelistech-2": Color(#colorLiteral(red: 1, green: 0.8509803922, blue: 0.2980392157, alpha: 1)),
        "filterrotelistech-3": Color(#colorLiteral(red: 0.937254902, green: 0.5490196078, blue: 0.1058823529, alpha: 1)),
        "filterrotelistech-4": Color(#colorLiteral(red: 0.8901960784, green: 0.4039215686, blue: 0.06274509804, alpha: 1)),
        "filterrotelistech-5": Color(#colorLiteral(red: 0.8666666667, green: 0.2470588235, blue: 0.07843137255, alpha: 1)),
        "filterrotelistech-6": Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    ]

    var symbolName: String
    var pointSize: CGFloat = 24
    var color: Color?

    var body: some View {
        Image(uiImage: Self.symbol(for: symbolName, with: pointSize))
            .renderingMode(Image.TemplateRenderingMode.template)
            .foregroundColor(color ?? Self.symbolColors[symbolName] ?? .primary)
            .alignmentGuide(VerticalAlignment.firstTextBaseline) { $0[VerticalAlignment.center] + pointSize * 0.375 }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                SymbolView(symbolName: "filterentwicklungatlas-1")
                Text(verbatim: "L Align")
                SymbolView(symbolName: "filterlebensraum-9")
                Text(verbatim: "Byjq")
                SymbolView(symbolName: "filterlebensraum-5", color: .green)
            }
            .font(.title)
            .padding()
            .previewLayout(.fixed(width: 300, height: 70))

            HStack {
                SymbolView(symbolName: "filterentwicklungatlas-1")
                Text(verbatim: "L Align")
                SymbolView(symbolName: "filterlebensraum-9")
                Text(verbatim: "Byjq")
                SymbolView(symbolName: "filterlebensraum-5", color: .green)
            }
            .font(.title)
            .previewLayout(.fixed(width: 300, height: 70))
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
        }
    }
}
