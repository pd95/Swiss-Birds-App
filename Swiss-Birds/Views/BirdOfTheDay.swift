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
            Text(species?.name ?? " ")
                .font(.largeTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.2)

            Button(action: {
                withAnimation {
                    self.state.restoredBirdId = self.speciesId
                    self.isPresented = false
                }
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

                    Text("Zum Vogel des Tages")
                }
            }
        }
        .onDisappear() {
            self.state.previousBirdOfTheDay = self.speciesId
        }

        // Fetch image and species data
        .onReceive(state.getBirdOfTheDay()) { (image) in
            self.image = image
            self.species = Species.species(for: self.speciesId)
        }

        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.primary, lineWidth: 0.5))
        .shadow(radius: 20)
        .padding()

        // Dimmed background
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(Color(.gray).opacity(0.4))
        .animation(Animation.easeInOut)
        .onTapGesture {
            withAnimation {
                self.isPresented = false
            }
        }
    }
}

struct BirdOfTheDay_Previews: PreviewProvider {
    static var previews: some View {
        BirdOfTheDay(isPresented: .constant(true), url: URL(string: "https://www.vogelwarte.ch/assets/images/headImages/vdt/3640.jpg")!, speciesId: 3640)
            .environmentObject(AppState.shared)
    }
}
