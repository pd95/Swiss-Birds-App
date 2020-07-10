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
    let speciesId: Species.Id

    @State private var image : UIImage?
    @State private var species: Species?

    var body: some View {
        VStack {
            Text("Vogel des Tages")
                .font(.title)

            Button(action: {
                self.isPresented = false
                self.state.showBird(self.speciesId)
                self.state.donateBirdOfTheDayIntent()
            }) {
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: 320, maxHeight: 220)
                        .background(
                            Group {
                                if image != nil {
                                    Image(uiImage: image!)
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                else {
                                    ActivityIndicatorView()
                                }
                            })
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 0.5))

                    Text(species?.name ?? " ")
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .animation(nil)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibility(identifier: "showBirdOfTheDay")
        .accessibility(label: Text("Vogel des Tages: \(species?.name ?? "")"))
        .accessibility(hint: Text("Zeige Details zum Vogel des Tages an."))
        .overlay(dismissButton, alignment: .topLeading)
        .animation(.easeIn)
        .onAppear() {
            self.state.getBirdOfTheDay()
        }
        .onDisappear() {
            self.state.previousBirdOfTheDay = self.speciesId
        }

        // Fetch image and species data
        .onReceive(self.state.$birdOfTheDayImage) { (image) in
            withAnimation(.none) {
                self.image = image
                self.species = Species.species(for: self.speciesId)
            }
        }

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
        .accessibility(identifier: "dismissBirdOfTheDay")
        .accessibility(label: Text("Schliessen"))
    }
}

struct BirdOfTheDay_Previews: PreviewProvider {
    static var previews: some View {
        BirdOfTheDay(isPresented: .constant(true), url: URL(string: "https://www.vogelwarte.ch/assets/images/headImages/vdt/3640.jpg")!, speciesId: 3640)
            .environmentObject(AppState.shared)
    }
}
