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
            let image = CIImage(image: resizedImage)
            filter.setValue(image, forKey: kCIInputImageKey)
            guard let result = filter.outputImage else { return resizedImage }
            return UIImage(ciImage: result)
        }
    }

    /// resize given image to smaller square
    ///
    /// - Parameter newSize: square size to resize to
    /// - Returns: resized image
    func resize(to newSize: CGSize) -> AnyObserver<UIImage> {
        return mapObserver {(croppedImage: UIImage) -> UIImage in
            let resizedImage = croppedImage
            return resizedImage
        }
    }

    /// Crop image
    func crop() -> AnyObserver<ImageCropInfo> {
        return mapObserver {(original: UIImage, cropRect: CGRect) -> UIImage in
            let croppedImage = original
            return croppedImage
        }
    }
}
extension ObserverType where E == ImageCropInfo {
    /// Adjust crop rect to maintain original image aspect ratio while center around square
    func adjustCentering() -> AnyObserver<ImageCropInfo> {
        return mapObserver {(original: UIImage, faceRect: CGRect) -> ImageCropInfo in
            let adjustCropRect = faceRect
            return (original: original, rect: adjustCropRect)
        }
    }

    /// Detect face in given image. If none, return full image
    func detectFace() -> AnyObserver<UIImage> {
        return mapObserver {(original: UIImage) -> ImageCropInfo in
            let faceRect = CGRect.zero
            return (original: original, rect: faceRect)
        }
    }
}
