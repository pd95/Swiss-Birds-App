//
//  Languages.swift
//  Swiss-Birds
//
//  Created by Philipp on 26.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

typealias LanguageIdentifier = String

let availableLanguages: [LanguageIdentifier] = ["de","fr","it","en"]
let preferredLanguageOrder: [LanguageIdentifier] = {
    var languages = [LanguageIdentifier]()
    var testLanguages = availableLanguages
    while testLanguages.isEmpty == false {
        let language = Bundle.preferredLocalizations(from: testLanguages).first!
        languages.append(language)
        if let index = testLanguages.firstIndex(of: language) {
            testLanguages.remove(at: index)
        }
    }
    return languages
}()
let primaryLanguage: LanguageIdentifier = preferredLanguageOrder.first!
