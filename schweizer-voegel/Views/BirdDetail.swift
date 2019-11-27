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
        ScrollView {
            VStack(alignment: .leading) {
                Text(bird.alternateName)
                    .font(.body)
                Image("assets/\(bird.primaryPictureName).jpg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("assets/\(bird.secondaryPictureName).jpg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding()
        }
        .navigationBarTitle(bird.name)
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BirdDetail(bird: allSpecies[3])
        }
        .environmentObject(ApplicationState())
    }
}
