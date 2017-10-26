//
//  ImageProcessing+Rx.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 26.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift
import CoreImage
typealias ImageCropInfo = (original: UIImage, rect: CGRect)
extension ObserverType where E == UIImage {
    /// Apply monochrome filter to the given image
    ///
    /// - Returns: Filtered image
    func apply(filter: CIFilter) -> AnyObserver<UIImage> {
        return self.mapObserver {(resizedImage: UIImage) -> UIImage in
            let context = CIContext()
            let image = CIImage(image: resizedImage)
            filter.setValue(image, forKey: kCIInputImageKey)
            guard let result = filter.outputImage else { return resizedImage }
            guard let cgImage = context.createCGImage(result, from: result.extent) else { return resizedImage }
            return UIImage(cgImage: cgImage)
        }
    }

    /// resize given image to smaller square
    ///
    /// - Parameter newSize: square size to resize to
    /// - Returns: resized image
    func resize(to newSize: CGSize) -> AnyObserver<UIImage> {
        return mapObserver {(croppedImage: UIImage) -> UIImage in
            defer {
                UIGraphicsEndImageContext()
            }
            UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.main.scale)
            croppedImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
                return croppedImage
            }
            return resizedImage
        }
    }

    /// Crop image
    func crop() -> AnyObserver<ImageCropInfo> {
        return mapObserver {(original: UIImage, cropRect: CGRect) -> UIImage in
            guard let croppedImage = original.cgImage?.cropping(to: cropRect) else { return original }
            return UIImage(cgImage: croppedImage)
        }
    }
}
extension ObserverType where E == ImageCropInfo {
    /// Adjust crop rect to maintain original image aspect ratio while center around square
    func adjustCentering() -> AnyObserver<ImageCropInfo> {
        return mapObserver {(original: UIImage, faceRect: CGRect) -> ImageCropInfo in
            func squareAroundCenter(rect: CGRect) -> CGRect {
                let newEdge = max(rect.width, rect.height)
                let dw = (newEdge - rect.width) / 2.0
                let dh = (newEdge - rect.height) / 2.0
                return CGRect(x: rect.minX - dw,
                              y: rect.minY - dh,
                              width: newEdge,
                              height: newEdge)
            }
            func center(_ square: CGRect, inside bounds: CGSize) -> CGRect {
                var rect = square
                if rect.minX < 0 {
                    let c = 0 - rect.minX
                    rect = CGRect(x: 0, y: rect.minY + c, width: rect.width - (2*c), height: rect.height - (2*c))
                }

                if rect.maxX > bounds.width {
                    let c = rect.maxX - bounds.width
                    rect = CGRect(x: rect.minX + (2*c), y: rect.minY + c, width: rect.width - (2*c), height: rect.height - (2*c))
                }
                if rect.minY < 0 {
                    let c = 0 - rect.minY
                    rect = CGRect(x: rect.minX + c, y: 0, width: rect.width - (2*c), height: rect.height - (2*c))
                }
                if rect.maxY > bounds.height {
                    let c = rect.maxY - bounds.height
                    rect = CGRect(x: rect.minX + c, y: rect.minY + (2*c), width: rect.width - (2*c), height: rect.height - (2*c))
                }
                return rect
            }
            let square = squareAroundCenter(rect: faceRect)
            return (original: original,
                    rect: center(square, inside: original.size))
        }
    }

    /// Detect face in given image. If none, return full image
    func detectFace() -> AnyObserver<UIImage> {
        return mapObserver {(original: UIImage) -> ImageCropInfo in
            let faceRect = CGRect(x: 0.0, y: 0.0, width: original.size.width, height: original.size.height)
            return (original: original, rect: faceRect)
        }
    }
}
