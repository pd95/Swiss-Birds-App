//
//  BirdDetail.swift
//  schweizer-voegel
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct BirdDetail: View {
    var bird: Species

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(bird.breadCrumbImageName)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                Text(bird.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            Image(bird.primaryPictureName)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image(bird.secondaryPictureName)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
//        .navigationBarTitle(bird.name, displayMode: .inline)
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BirdDetail(bird: allSpecies[3])
        }
    }
}
