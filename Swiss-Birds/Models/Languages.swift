//
//  Languages.swift
//  Swiss-Birds
//
//  Created by Philipp on 26.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

let availableLanguages = ["de","fr","it","en"]
let language = Bundle.preferredLocalizations(from: availableLanguages).first!
