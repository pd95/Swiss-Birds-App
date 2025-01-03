//
//  AppState_PreviewWrapper.swift
//  SwissBirds
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
                ProgressView()
                    .controlSize(.large)
            } else {
                content()
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    AppState_PreviewWrapper {
        Text(verbatim: "AppState loaded")
    }
    .environmentObject(AppState.shared)
}
