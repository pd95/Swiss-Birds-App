//
//  AppState_PreviewWrapper.swift
//  Swiss-Birds
//
//  Created by Philipp on 17.11.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct AppState_PreviewWrapper<Content: View>: View {
    @EnvironmentObject private var state: AppState

    let content: () -> Content

    var body: some View {
        NavigationView {
            if state.initialLoadRunning {
                ActivityIndicatorView(style: .large)
            } else {
                content()
            }
        }
    }
}

struct AppState_PreviewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        AppState_PreviewWrapper {
            Text("AppState loaded")
        }
        .environmentObject(AppState.shared)
    }
}
