//
//  BirdOfTheDay.swift
//  Swiss-Birds
//
//  Created by Philipp on 26.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct BirdOfTheDay: View {
    @EnvironmentObject private var state : AppState
    @Binding var isPresented: Bool

    let url: URL
    let speciesId: Int

    var body: some View {
        VStack {
            Text("Bird of the day")
                .font(.title)

            Button(action: {
                self.isPresented = false
            }) {
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: 320, maxHeight: 220)
                        .background(
                            Group {
                                if state.image != nil {
                                    Image(uiImage: state.image!)
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                else {
                                    if !self.state.loadImage {
                                        Button("Load Image") {
                                            self.state.loadImage = true
                                            // Fetch image and species data
                                            self.state.getBirdOfTheDay()
                                        }
                                    }
                                    else {
                                        ActivityIndicatorView()
                                    }
                                }
                            })
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 0.5))
                }
            }
        }
        .overlay(dismissButton, alignment: .topTrailing)
        .animation(.easeIn)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.primary, lineWidth: 0.5))
        .shadow(radius: 20)
        .padding()
    }

    var dismissButton: some View {
        Button(action: {
            self.isPresented = false
        }) {
            Image(systemName: "xmark")
                .imageScale(.large)
                .foregroundColor(Color.secondary)
                .padding(10)
        }
    }
}

struct BirdOfTheDay_Previews: PreviewProvider {
    static var previews: some View {
        BirdOfTheDay(isPresented: .constant(true), url: URL(string: "https://www.vogelwarte.ch/assets/images/headImages/vdt/3640.jpg")!, speciesId: 3640)
            .environmentObject(AppState())
    }
}
