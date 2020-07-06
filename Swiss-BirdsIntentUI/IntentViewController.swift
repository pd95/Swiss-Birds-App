//
//  IntentViewController.swift
//  Swiss-BirdsIntentUI
//
//  Created by Philipp on 04.07.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import IntentsUI
import Combine


class IntentViewController: UIViewController, INUIHostedViewControlling {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {

        guard let response = interaction.intentResponse as? BirdOfTheDayIntentResponse,
            let url = response.birdImageURL,
            let birdName = response.birdName
        else {
            completion(false, Set(), .zero)
            return
        }

        // Try a specific aspect ratio: 1.7 : 1
        let maxHeight: CGFloat = 450.0
        var desiredSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.width / 1.7)
        if desiredSize.height > maxHeight {
            desiredSize.height = maxHeight
            desiredSize.width = maxHeight * 1.7
        }

        activityIndicator.startAnimating()

        label.text = birdName
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] image in
                self?.imageView.image = image
                self?.activityIndicator.stopAnimating()
            })

        completion(true, parameters, desiredSize)
    }
}
