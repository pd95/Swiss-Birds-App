//
//  SwiftUI_Utilities.swift
//  schweizer-voegel
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import Combine

class RemoteImageURL: ObservableObject {
    @Published var data = Data()
    
    init(imageURL: URL) {
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.data = data
            }
        }.resume()
    }
}

struct ImageViewContainer: View {
    @ObservedObject var remoteImageURL: RemoteImageURL
    
    init(imageURL: URL) {
        remoteImageURL = RemoteImageURL(imageURL: imageURL)
    }

    var body: some View {
        Image(uiImage:
            (remoteImageURL.data.isEmpty) ? UIImage(systemName: "circle")! : UIImage(data: remoteImageURL.data)!
        )
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ImageViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewContainer(imageURL: URL(string: "https://developer.apple.com/home/images/hero-apple-platforms/large_2x.jpg")!)
    }
}
