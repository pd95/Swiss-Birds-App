//
//  UIImage-resize.swift
//  SwissBirds
//
//  Created by Philipp on 04.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    static func resizedImage(from url: URL, displaySize size: CGSize, displayScale: CGFloat = 2) -> UIImage {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            // Handle the failure to create image source
            fatalError("Failed to create image source from URL: \(url)")
        }

        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) * displayScale,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            fatalError("🔴 Unable to create thumbnail from URL: \(url)")
        }

        let resizedImage = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)

        return resizedImage
    }
}
