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
        let images = UIImage.resizedImages(from: Bundle.placeholderJpg, displaySize: context.displaySize)

        return SimpleEntry(speciesID: speciesID, name: name, date: date, image: images.image, bgImage: images.bgImage)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let speciesID = -1
        let name = "Blaumeise"
        let imageData = Bundle.placeholderJpg
        let reloadDate = Date.distantFuture
        let images = UIImage.resizedImages(from: imageData, displaySize: context.displaySize)

        completion(SimpleEntry(speciesID: speciesID, name: name, date: reloadDate, image: images.image, bgImage: images.bgImage))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        DataFetcher.shared.getBirdOfTheDay { (speciesID, name, url, reloadDate) in
            print(#function, context.family)

            // Get widget size and display scale
            let displaySize = CGSize(width: ceil(context.displaySize.height/9.0*16*1.48), height: context.displaySize.height)
            let displayScale = context.environmentVariants.displayScale?.reduce(1, { max($0, $1) }) ?? 1

            let images = UIImage.resizedImages(from: url, displaySize: displaySize, displayScale: displayScale)
            let entry = SimpleEntry(speciesID: speciesID, name: name, date: reloadDate, image: images.image, bgImage: images.bgImage)
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

    static var example: SimpleEntry {
        let images = UIImage.resizedImages(from: Bundle.placeholderJpg)
        return SimpleEntry(speciesID: 3800, name: "Blaumeise", date: Date.distantFuture, image: images.image, bgImage: images.bgImage)
    }

#if DEBUG
    static var exampleReal: SimpleEntry {
        let images = UIImage.resizedImages(from: Bundle.realPlaceholderJpg)
        return SimpleEntry(speciesID: 2980, name: "Hohltaube", date: Date.distantFuture, image: images.image, bgImage: images.bgImage)
    }
#endif
}

struct BirdOfTheDayWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        let isSmall = family == .systemSmall
        VStack(spacing: 0) {
            if family != .systemMedium {
                Text("Bird of the Day")
                    .font(isSmall ? .headline : .title)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.bottom, isSmall ? 4 : 8)
            }

            Color.clear
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                .background(
                    Image(uiImage: entry.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )

            Text(entry.name)
                .font(family == .systemLarge ? .title : .title3.bold())
                .padding(.horizontal, 8)
                .padding(.top, isSmall ? 4 : 0)
                .padding(.bottom, 4)
        }
        .foregroundColor(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
                Image(uiImage: entry.bgImage)
                    .resizable(resizingMode: .tile)
        )
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
        .supportedFamilies(families)
    }

    var families: [WidgetFamily] {
        if #available(iOSApplicationExtension 15.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
}

struct BirdOfTheDayWidget_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BirdOfTheDayWidgetEntryView(entry: .example)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            #if DEBUG
            BirdOfTheDayWidgetEntryView(entry: .exampleReal)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            BirdOfTheDayWidgetEntryView(entry: .exampleReal)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            BirdOfTheDayWidgetEntryView(entry: .exampleReal)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            if #available(iOSApplicationExtension 15.0, *) {
                BirdOfTheDayWidgetEntryView(entry: .exampleReal)
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            }
            #endif
        }
    }
}
