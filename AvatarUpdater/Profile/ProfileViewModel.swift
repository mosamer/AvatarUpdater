//
//  ProfileViewModel.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift
import RxCocoa

/// A type representing API for profile view model
protocol ProfileAPI {
    /// Fetch image from given URL
    ///
    /// - Parameter url: image URL
    /// - Returns: fetched image object
    func image(from url: URL) -> Observable<UIImage>
}
class ProfileViewModel: ProfileViewModelType {

    private let user: User
    private let api: ProfileAPI
    init(user: User, api: ProfileAPI) {
        self.user = user
        self.api = api
    }
    
    var userAvatar: Driver<UIImage> {
        return Observable
            .just(user)
            .map { $0.avatarURL }
            .flatMap {[unowned self] url -> Observable<UIImage> in
                guard let url = url else { return Observable.just(#imageLiteral(resourceName: "default_avatar")) }
                return self.api.image(from: url)
            }
            .asDriver(onErrorJustReturn: #imageLiteral(resourceName: "default_avatar"))
    }
    var userEmail: Driver<String> {
        return Driver.just(user).map { $0.email }
    }
}
