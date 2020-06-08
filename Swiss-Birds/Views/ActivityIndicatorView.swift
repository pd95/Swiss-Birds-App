//
//  ActivityIndicatorView.swift
//  SRF Kids
//
//  Created by Philipp on 01.02.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

/// `ActivityIndicatorView` is a wrapper class for the UIKit `UIActivityIndicatorView`
///
struct ActivityIndicatorView: UIViewRepresentable {
    let style : UIActivityIndicatorView.Style

    init(style: UIActivityIndicatorView.Style = .large) {
        self.style = style
    }

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.startAnimating()
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    }

    typealias UIViewType = UIActivityIndicatorView

}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView(style: .large)
    }
}
