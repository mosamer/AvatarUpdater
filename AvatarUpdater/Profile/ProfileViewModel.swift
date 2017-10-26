//
//  ProfileViewModel.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift
import RxCocoa
import Action

/// A type representing API for profile view model
protocol ProfileAPI {
    /// Fetch image from given URL
    ///
    /// - Parameter url: image URL
    /// - Returns: fetched image object
    func image(from url: URL) -> Observable<UIImage>
    /// Upload user's picked avatar
    ///
    /// - Parameter image: Avatar image
    /// - Parameter user: User to update
    /// - Returns: updated avatar URL
    func upload(avatar image: UIImage, for user: User) -> Observable<URL>
}
class ProfileViewModel: ProfileViewModelType {

    private let user: User
    private let api: ProfileAPI
    private let uploadAction: Action<UIImage, URL>
    private let bag = DisposeBag()
    init(user: User, api: ProfileAPI, updater: @escaping UserUpdater) {
        self.user = user
        self.api = api
        uploadAction = Action {image in
            api.upload(avatar: image, for: user)
        }
        _pickedImage
            .bind(to: uploadAction.inputs)
            .disposed(by: bag)

        uploadAction
            .elements
            .map { user.updatingAvatarURL($0)}
            .subscribe(onNext: updater)
            .disposed(by: bag)
    }
    
    var userAvatar: Driver<UIImage> {
        let fetched = Observable
            .just(user)
            .map { $0.avatarURL }
            .flatMap {[unowned self] url -> Observable<UIImage> in
                guard let url = url else { return Observable.just(#imageLiteral(resourceName: "default_avatar")) }
                return self.api.image(from: url)
            }
            .asDriver(onErrorJustReturn: #imageLiteral(resourceName: "default_avatar"))

        let picked = _pickedImage
            .asDriver(onErrorJustReturn: #imageLiteral(resourceName: "default_avatar"))
        return Driver.merge([fetched, picked]).distinctUntilChanged()
    }
    var userEmail: Driver<String> {
        return Driver.just(user).map { $0.email }
    }
    private let _pickedImage = PublishSubject<UIImage>()
    var pickedImage: AnyObserver<UIImage> {
        // Chain order is backward as it map observers
        return _pickedImage.asObserver()
            .applyMonchromeFilter()
            .resize(to: CGSize(width: 240.0, height: 240.0))
            .crop()
            .adjustCentering()
            .detectFace()
        // picked image will get into detectFace() and move upward to _pickedImage ;)
    }

    var isLoading: Driver<Bool> {
        return uploadAction.executing.asDriver(onErrorJustReturn: false)
    }
}
typealias ImageCropInfo = (original: UIImage, rect: CGRect)
extension ObserverType where E == UIImage {
    /// Apply monochrome filter to the given image
    ///
    /// - Returns: Filtered image
    func applyMonchromeFilter() -> AnyObserver<UIImage> {
        return self.mapObserver {(resizedImage: UIImage) -> UIImage in
            let filteredImage = resizedImage
            return filteredImage
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
