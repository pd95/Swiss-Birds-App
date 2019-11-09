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
            VStack {
                Image(bird.primaryPictureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image(bird.secondaryPictureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
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
