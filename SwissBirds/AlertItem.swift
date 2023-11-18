//
//  AlertItem.swift
//  SwissBirds
//
//  Created by Philipp on 07.08.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title = Text("")
    var message: Text?
    var dismissButton: Alert.Button?
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?

    var alert: Alert {
        guard let primaryButton = primaryButton, let secondaryButton = secondaryButton else {
            return Alert(title: title, message: message, dismissButton: dismissButton)
        }
        return Alert(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondaryButton)
    }
}
