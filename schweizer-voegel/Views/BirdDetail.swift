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
            HStack {
                Image("\(bird.id)")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                Text(bird.name)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            Image("\(bird.id)_0")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image("\(bird.id)_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
        //.navigationBarTitle(bird.name)
    }
}

struct BirdDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BirdDetail(bird: species[0])
        }
    }
}
