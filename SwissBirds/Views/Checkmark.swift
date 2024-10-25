//
//  Checkmark.swift
//  SwissBirds
//
//  Created by Philipp on 28.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct Checkmark: View {
    var checked = true

    let checkmark = Image(systemName: "checkmark")

    var body: some View {
        Group {
            if checked {
                checkmark
            } else {
                checkmark.hidden()
            }
        }
    }
}

struct Checkmark_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HStack {
                Checkmark(checked: true)
                Text(verbatim: "Checked")
            }
            HStack {
                Checkmark(checked: false)
                Text(verbatim: "Unchecked")
            }
        }
    }
}
