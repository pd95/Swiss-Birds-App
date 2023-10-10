//
//  BirdOfTheDayWidget.swift
//  BirdOfTheDayWidget
//
//  Created by Philipp on 26.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct BirdOfTheDayProvider: TimelineProvider {
    // Helper function to extract relevant image parts from image data
    func placeholder(in context: Context) -> SimpleEntry {
        let speciesID = -1
        let name = "Blaumeise"
        let date = Date.distantFuture

        let displaySize = CGSize(width: ceil(context.displaySize.height/9.0*16*1.48), height: context.displaySize.height)
        let images = UIImage.resizedImages(from: Bundle.placeholderJpg, displaySize: displaySize)

        return SimpleEntry(speciesID: speciesID, name: name, date: date, image: images.image, bgImage: images.bgImage)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let speciesID = -1
        let name = "Blaumeise"
        let imageData = Bundle.placeholderJpg
        let reloadDate = Date.distantFuture

        let displaySize = CGSize(width: ceil(context.displaySize.height/9.0*16*1.48), height: context.displaySize.height)
        let images = UIImage.resizedImages(from: imageData, displaySize: displaySize)

        completion(SimpleEntry(speciesID: speciesID, name: name, date: reloadDate, image: images.image, bgImage: images.bgImage))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        DataFetcher.shared.getBirdOfTheDay { (speciesID, name, url, reloadDate) in
            print(#function, context.family, context.displaySize)

            // Get widget size and display scale
            let displaySize = CGSize(width: ceil(context.displaySize.height/9.0*16*1.48), height: context.displaySize.height)
            let displayScale = UIScreen.main.scale

            let (image, bgImage) = UIImage.resizedImages(from: url, displaySize: displaySize, displayScale: displayScale)
            let entry = SimpleEntry(speciesID: speciesID, name: name, date: reloadDate, image: image, bgImage: bgImage)
            let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let speciesID: Int
    let name: String
    let date: Date

    let image: UIImage
    let bgImage: UIImage
}

struct BirdOfTheDayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family: WidgetFamily

    var entry: SimpleEntry

    private var textFont: Font {
        if family == .systemLarge {
            .title
        }
        else if family == .systemSmall {
            .caption.bold()
        }
        else {
            .title3.bold()
        }
    }

    var body: some View {
        let isSmall = family == .systemSmall
        VStack(spacing: 0) {
            if family != .systemMedium {
                Text("Bird of the Day")
                    .padding(.horizontal, 8)
                    .padding(.vertical, isSmall ? 4 : 8)
                    .frame(maxHeight: .infinity)
            }

            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                .layoutPriority(1)

            Text(entry.name)
                .padding(.horizontal, 4)
                .padding(.top, isSmall ? 4 : 0)
                .padding(.bottom, 4)
                .frame(maxHeight: .infinity)
        }
        .font(textFont)
        .foregroundColor(.white)
        .lineLimit(1)
        .truncationMode(.tail)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(entry.bgImage, family: family)
    }
}

extension View {
    @ViewBuilder
    func widgetBackground(_ uiImage: UIImage, family: WidgetFamily) -> some View {
        let bgImage = Image(uiImage: uiImage)
            .resizable(resizingMode: .tile)
            .aspectRatio(contentMode: .fill)

        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(bgImage)
            }
        } else {
            background(bgImage)
        }
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        }
        else {
            return self
        }
    }
}

@main
struct BirdOfTheDayWidget: Widget {
    let kind: String = "BirdOfTheDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BirdOfTheDayProvider()) { entry in
            BirdOfTheDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bird of the Day")
        .description("This widget shows the curated bird of the day.")
        .supportedFamilies(Self.supportedFamilies)
        .contentMarginsDisabledIfAvailable()
    }

    static var supportedFamilies: [WidgetFamily] {
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    }

    static var familiesWithText: [WidgetFamily] {
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    }
}

struct BirdOfTheDayWidget_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BirdOfTheDayWidgetEntryView(entry: .exampleReal2)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
//            if #available(iOSApplicationExtension 15.0, *) {
//                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
//            }
        }
    }
}
