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
                Image(bird.primaryPictureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image(bird.secondaryPictureName)
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
    }
}
