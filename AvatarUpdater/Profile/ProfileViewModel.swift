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
    /// - Returns: updated avatar URL
    func upload(avatar image: UIImage) -> Observable<URL>
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
            api.upload(avatar: image)
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

        let picked = _pickedImage.asDriver(onErrorJustReturn: #imageLiteral(resourceName: "default_avatar"))
        return Driver.merge([fetched, picked]).distinctUntilChanged()
    }
    var userEmail: Driver<String> {
        return Driver.just(user).map { $0.email }
    }
    private let _pickedImage = PublishSubject<UIImage>()
    var pickedImage: AnyObserver<UIImage> { return _pickedImage.asObserver()}
}
