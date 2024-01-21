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

    func placeholder(in context: Context) -> SimpleEntry {
        let speciesID = -1
        let name = "Blaumeise"
        let date = Date.distantFuture

        let images = UIImage.resizedImage(from: Bundle.placeholderJpg, displaySize: context.displaySize)
        return SimpleEntry(speciesID: speciesID, name: name, date: date, image: images)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let speciesID = -1
        let name = "Blaumeise"
        let imageData = Bundle.placeholderJpg
        let reloadDate = Date.distantFuture

        let image = UIImage.resizedImage(from: imageData, displaySize: context.displaySize)
        completion(SimpleEntry(speciesID: speciesID, name: name, date: reloadDate, image: image))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let displayScale = UIScreen.main.scale

        DataFetcher.shared.getBirdOfTheDay { (speciesID, name, url, reloadDate) in

            let image = UIImage.resizedImage(from: url, displaySize: context.displaySize, displayScale: displayScale)
            let entry = SimpleEntry(speciesID: speciesID, name: name, date: reloadDate, image: image)
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
        ZStack {
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)

            Text(entry.name)
                .frame(maxWidth: .infinity)
                .font(textFont)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .widgetBackground()
    }
}

extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
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
        .contentMarginsDisabled()
    }

    static var supportedFamilies: [WidgetFamily] {
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    }

    static var familiesWithText: [WidgetFamily] {
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    }
}

#if DEBUG
struct BirdOfTheDayWidget_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BirdOfTheDayWidgetEntryView(entry: .exampleReal)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")

            BirdOfTheDayWidgetEntryView(entry: .exampleReal2)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")

            BirdOfTheDayWidgetEntryView(entry: .exampleReal)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }

}

/*
#Preview("Small2", as: .systemSmall, widget: {
    BirdOfTheDayWidget()
}, timeline: {
    SimpleEntry.exampleReal
    SimpleEntry.exampleReal2
})

#Preview("Medium3", as: .systemMedium, widget: {
    BirdOfTheDayWidget()
}, timeline: {
    SimpleEntry.exampleReal
    SimpleEntry.exampleReal2
})

#Preview("Large4", as: .systemLarge, widget: {
    BirdOfTheDayWidget()
}, timeline: {
    SimpleEntry.exampleReal
    SimpleEntry.exampleReal2
})
*/
#endif
