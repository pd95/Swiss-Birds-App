//
//  UIImage-resize.swift
//  Swiss-Birds
//
//  Created by Philipp on 04.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    @available(iOS 14.0, *)
    static func resizedImages(from url: URL, displaySize size: CGSize = CGSize(width: 338, height: 354), displayScale: CGFloat = 2) -> (image: UIImage, bgImage: UIImage) {
        let context = CIContext()
        guard let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, nil as CFDictionary?) else {
            fatalError("🔴 unable to get input image")
        }
        let inputImage = CIImage(cgImageSource: cgImageSource, index: 0)

        // Extract center of image
        guard let filter = CIFilter(name: "CIStretchCrop") else {
            fatalError("🔴 unable to create CICrop filter")
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(CIVector(x: size.width * displayScale, y: size.height * displayScale), forKey: "inputSize")
        filter.setValue(NSNumber(value: 1), forKey: "inputCropAmount")
        filter.setValue(NSNumber(value: 0), forKey: "inputCenterStretchAmount")

        guard let outputImage = filter.outputImage else {
            fatalError("🔴 unable to create outputImage")
        }

        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            fatalError("🔴 unable to create cgImage for outputImage")
        }
        let image =  UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)

        // Extract background by cropping left part of image
        guard let filter = CIFilter(name: "CICrop") else {
            fatalError("🔴 unable to create CICrop filter")
        }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(CIVector(cgRect: CGRect(origin: .zero, size: size)), forKey: "inputRectangle")

        guard let outputImage = filter.outputImage else {
            fatalError("🔴 unable to create outputImage")
        }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            fatalError("🔴 unable to create cgImage for outputImage")
        }
        let bgImage = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
        return (image, bgImage)
    }
}
