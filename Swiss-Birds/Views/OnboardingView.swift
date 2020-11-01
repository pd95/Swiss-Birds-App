//
//  OnboardingView.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.11.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {

    @State private var showSidebarHint = true

    var body: some View {
        ZStack {
            if showSidebarHint {
                HStack {
                    Image(systemName: "arrow.up")
                    Text("Liste der Vögel anzeigen")
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            VStack {
                Text("Vögel der Schweiz")
                    .font(.largeTitle)
                    .bold()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 500)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                    .padding()
            }
            .padding()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)) { notification in
                guard let device = notification.object as? UIDevice else {
                    return
                }
                showSidebarHint = device.orientation == .unknown ||
                    device.orientation.isPortrait && (
                        device.orientation != .faceUp ||
                        device.orientation != .faceDown
                    )
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
