//
//  Extensions.swift
//  Swiss-Birds
//
//  Created by Philipp on 24.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    /// Activity type used in state restoration
    var activityType: String {
        return Bundle.main.infoDictionary?["NSUserActivityTypes"].flatMap { ($0 as? [String])?.first } ?? ""
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
