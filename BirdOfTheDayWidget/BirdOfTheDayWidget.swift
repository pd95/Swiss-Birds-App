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


struct Provider: IntentTimelineProvider {

    static let placeholderImage = UIImage(named: "Placeholder")!

    let dataFetcher = DataFetcher.shared

    func placeholder(in context: Context) -> SimpleEntry {
        let speciesID = -1
        let name = "Blaumeise"
        let image = Self.placeholderImage
        let date = Date()

        return SimpleEntry(speciesID: speciesID, name: name, image: image, date: date, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let speciesID = -1
        let name = "Blaumeise"
        let image = Self.placeholderImage
        let reloadDate = Date()
        let entry = SimpleEntry(speciesID: speciesID, name: name, image: image, date: reloadDate, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        dataFetcher.getBirdOfTheDay { (speciesID, name, image, reloadDate) in
            let entry = SimpleEntry(speciesID: speciesID, name: name, image: image, date: reloadDate, configuration: configuration)
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
    let configuration: ConfigurationIntent
}

struct BirdOfTheDayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Image(uiImage: entry.image)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

@main
struct BirdOfTheDayWidget: Widget {
    let kind: String = "BirdOfTheDayWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            BirdOfTheDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bird Of The Day Widget")
        .description("This widget shows the curated bird of the day.")
    }
}

struct BirdOfTheDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        BirdOfTheDayWidgetEntryView(entry: SimpleEntry(speciesID: -1, name: "Blaumeise", image: Provider.placeholderImage, date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
