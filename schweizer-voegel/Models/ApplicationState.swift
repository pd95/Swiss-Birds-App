//
//  ApplicationState.swift
//  schweizer-voegel
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

class ApplicationState : ObservableObject {
    @Published var searchText : String = ""
    @Published var selectedFilters = [FilterType:[Int]]()
    @Published var currentBird : Species?
}
