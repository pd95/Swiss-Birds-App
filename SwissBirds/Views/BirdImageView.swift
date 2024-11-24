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
    var isLoading: Bool

    var body: some View {
        VStack {
            if isLoading {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .overlay(ProgressView())
                    .aspectRatio(1.5, contentMode: .fit)
            } else {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .foregroundStyle(.red)
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 60)
                        )
                        .aspectRatio(1.5, contentMode: .fit)
                }
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

#Preview {
    BirdImageView(image: UIImage(named: "Logo")!, author: "Donald Duck", description: "Ein Vogel", isLoading: false)
}
