//
//  Characteristic.swift
//  SwissBirds
//
//  Created by Philipp on 03.11.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

enum Characteristic: Identifiable {

    indirect case header(text: String, children: [Characteristic])
    case separator(Int? = nil)
    case text(label: String = "", text: String?, symbol: String = "")

    var id: String {
        let identifier: String
        switch self {
        case .header(text: let text, _):
            identifier = "header_\(text)"
        case .separator(let num):
            identifier = "separator_\(num ?? 1)"
        case .text(label: let label, text: let text, _):
            if let text = text {
                identifier = "text_\(label.isEmpty ? text : label)"
            } else {
                identifier = "text_\(label)"
            }
        }
        return identifier
    }

    var isEmpty: Bool {
        switch self {
        case let .header(_, children):
            let r = children.reduce(true) {$0 && $1.isEmpty}
            return r
        case let .text(_, text, _):
            let r = text == nil || text!.isEmpty
            return r
        default:
            return false
        }
    }

    var isHeader: Bool {
        switch self {
        case .header:
            return true
        default:
            return false
        }
    }

    var isSeparator: Bool {
        switch self {
        case .separator:
            return true
        default:
            return false
        }
    }

    var text: String {
        switch self {
        case let .header(text, _):
            return text
        case let .text(_, text, _):
            return text!
        default:
            return ""
        }
    }

    var label: String {
        switch self {
        case let .text(label, _, _):
            return label
        default:
            return ""
        }
    }

    var symbol: String {
        switch self {
        case let .text(_, _, symbol):
            return symbol
        default:
            return ""
        }
    }

    var children: [Characteristic] {
        switch self {
        case let .header(_, children):
            return children
        default:
            fatalError("This shouldn't happen!")
        }
    }

    static let example: [Characteristic] = [
        .header(text: "Merkmale", children: [
            .text(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Faucibus in ornare quam viverra orci sagittis eu volutpat odio. ")
        ]),
        .header(text: "Eigenschaften", children: [
            .text(label: FilterType.vogelgruppe.rawValue, text: "Spatzen", symbol: "filtervogelgruppe-52"),
            .text(label: "Laenge_cm", text: "10"),
            .text(label: "Spannweite_cm", text: "20"),
            .text(label: "Gewicht_g", text: "30"),
            .separator(1),
            .text(label: "Nahrung", text: "Insekten und würmer"),
            .text(label: "Lebensraum", text: "Wiese"),
            .text(label: "Zugverhalten", text: "Hausvogel"),
            .separator(2),
            .text(label: "Brutort", text: "Nest auf dem Baum"),
            .text(label: "Brutdauer_Tage", text: "10"),
            .text(label: "Jahresbruten", text: "1"),
            .text(label: "Gelegegroesse", text: "3-5"),
            .text(label: "Nestlingsdauer_Flugfaehigkeit_Tage", text: "11-13"),
            .separator(3),
            .text(label: "Hoechstalter_CH", text: "Unsterblich"),
            .text(label: "Hoechstalter_EURING", text: "13")
        ]),
        .header(text: "Status_in_CH", children: [
            .text(text: "In Schlössern und alten Burgen beim Zauberbrunnen")
        ]),
        .header(text: "Bestand", children: [
            .text(label: "Bestand", text: "1-2"),
            .text(label: "Rote_Liste_CH", text: ""),
            .text(label: "Prioritaetsart_Artenfoerderung", text: "Nein")
        ])
    ]

}
