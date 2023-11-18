//
//  BirdOfTheDay.swift
//  SwissBirds
//
//  Created by Philipp on 26.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct BirdOfTheDay: View {
    @EnvironmentObject private var state: AppState
    @Binding var isPresented: Bool

    let image: UIImage
    let species: Species

    var body: some View {
        VStack {
            Text("Vogel des Tages")
                .font(.title)

            Button(action: {
                isPresented = false
                state.showBird(species)
            }) {
                VStack {
                    Color.clear
                        .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                        .background(
                            Image(uiImage: image)
                                .resizable()
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fill)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 0.5))

                    Text(species.name)
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .hoverEffect()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibility(identifier: "showBirdOfTheDay")
        .accessibility(label: Text("Vogel des Tages: \(species.name)"))
        .accessibility(hint: Text("Zeige Details zum Vogel des Tages an."))
        .overlay(dismissButton, alignment: .topLeading)
        .onAppear {
            state.previousBirdOfTheDay = species.speciesId
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
            isPresented = false
        }) {
            Image(systemName: "xmark")
                .imageScale(.large)
                .foregroundColor(Color.secondary)
                .padding(10)
        }
        .hoverEffect()
        .accessibility(identifier: "dismissBirdOfTheDay")
        .accessibility(label: Text("Schliessen"))
    }
}

struct BirdOfTheDay_Previews: PreviewProvider {
    static var state = AppState.shared

    static var previews: some View {
        if let species = Species.species(for: 3640) {
            BirdOfTheDay(isPresented: .constant(true), image: UIImage(named: "Logo")!, species: species)
                .environmentObject(state)
        } else {
            ProgressView()
                .onAppear {
                    state.checkBirdOfTheDay(showAlways: true)
                }
        }
    }
}
