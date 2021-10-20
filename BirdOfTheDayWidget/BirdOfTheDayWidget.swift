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

struct Provider: TimelineProvider {

    static let placeholderImage = UIImage(named: "Placeholder")!

    let dataFetcher = DataFetcher.shared

    func placeholder(in context: Context) -> SimpleEntry {
        let speciesID = -1
        let name = "Blaumeise"
        let image = Self.placeholderImage
        let date = Date()

        return SimpleEntry(speciesID: speciesID, name: name, image: image, date: date)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let speciesID = -1
        let name = "Blaumeise"
        let image = Self.placeholderImage
        let reloadDate = Date()
        let entry = SimpleEntry(speciesID: speciesID, name: name, image: image, date: reloadDate)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        dataFetcher.getBirdOfTheDay { (speciesID, name, image, reloadDate) in
            let entry = SimpleEntry(speciesID: speciesID, name: name, image: image, date: reloadDate)
            let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let speciesID: Int
    let name: String
    let image: UIImage
    let date: Date

    static let example = SimpleEntry(speciesID: 3800, name: "Blaumeise", image: Provider.placeholderImage, date: Date())
    static let exampleReal1 = SimpleEntry(speciesID: 3800, name: "Blaumeise", image: UIImage(named: "RealPlaceholder")!, date: Date())
    static let exampleReal2 = SimpleEntry(speciesID: 710, name: "Common Shelduck", image: UIImage(named: "RealPlaceholder2")!, date: Date())
}

struct BirdOfTheDayWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        VStack(spacing: 0) {
            if family != .systemMedium {
                Text("Bird of the Day")
                    .font(family == .systemSmall ? .headline : .title)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.bottom, family == .systemSmall ? 4 : 8)
            }

            Color.clear
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                .background(
                    Image(uiImage: entry.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )

            Text(entry.name)
                .font(family == .systemLarge ? .title : Font.title3.bold())
                .padding(.horizontal, 8)
                .padding(.top, family == .systemSmall ? 4 : 0)
                .padding(.bottom, 4)
        }
        .foregroundColor(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(uiImage: entry.image)
                .resizable(resizingMode: .tile)
        )
    }
}

@main
struct BirdOfTheDayWidget: Widget {
    let kind: String = "BirdOfTheDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
        let example = SimpleEntry.example

        return Group {
            BirdOfTheDayWidgetEntryView(entry: example)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            BirdOfTheDayWidgetEntryView(entry: example)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            BirdOfTheDayWidgetEntryView(entry: example)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
