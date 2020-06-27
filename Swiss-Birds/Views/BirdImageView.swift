//
//  BirdImageView.swift
//  Swiss-Birds
//
//  Created by Philipp on 27.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct BirdImageView: View {
    var image : UIImage?
    var author : String
    var description : String

    var body: some View {
        VStack {
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            else {
                ActivityIndicatorView()
                    .padding(50)
            }
            HStack {
                Text(description)
                Spacer()
                Text("© \(author)")
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
        BirdImageView(image: nil, author: "Donald Duck", description: "Ein Vogel")
    }
}
