//
//  ProfileViewModel.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//
import RxCocoa
class ProfileViewModel: ProfileViewModelType {

    var userAvatar: Driver<UIImage> {
        return Driver.empty()
    }
    var userEmail: Driver<String> {
        return Driver.empty()
    }
}
