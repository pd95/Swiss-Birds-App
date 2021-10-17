//
//  ShareSheet.swift
//  Swiss-Birds
//
//  Created by Philipp on 22.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {

    struct Item: Identifiable {
        let id = UUID()
        let subject: String
        let activityItems: [Any]
    }

    let item: Item

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [context.coordinator], applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIActivityItemSource {
        let parent: ShareSheet

        init(_ parent: ShareSheet) {
            self.parent = parent
        }

        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return parent.item.activityItems.first!
        }

        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            return parent.item.activityItems.first!
        }

        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return parent.item.subject
        }
    }
}

struct ShareSheet_Previews: PreviewProvider {
    static var previews: some View {
        Color(.systemBackground)
            .sheet(isPresented: .constant(true), content: {
                ShareSheet(item: .init(subject: "Schweizerische Vogelwarte", activityItems: [VdsAPI.base]))
            })
    }
}
