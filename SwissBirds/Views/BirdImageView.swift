//
//  BirdImageView.swift
//  SwissBirds
//
//  Created by Philipp on 27.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct BirdImageView: View {
    var image: UIImage?
    var author: String
    var description: String

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .overlay(ProgressView())
                    .aspectRatio(1.5, contentMode: .fit)
            }
            HStack {
                Text(description)
                Spacer()
                Text("© \(author)", comment: "Copyright notice for photographer")
            }
            .padding([.leading, .bottom, .trailing], 8)
            .font(.caption)
        }
        .background(Color(.systemGray5))
        .cornerRadius(5)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Vogelbild zeigt \(description)"))
    }
}

struct BirdImageView_Previews: PreviewProvider {
    static var previews: some View {
        BirdImageView(image: UIImage(named: "Logo")!, author: "Donald Duck", description: "Ein Vogel")
    }
}
