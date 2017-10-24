//
//  LoginViewModel.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift
import Action

class LoginViewModel: LoginViewModelType {

    var email: AnyObserver<String> { return AnyObserver { _ in } }
    var password: AnyObserver<String> { return AnyObserver { _ in } }
    lazy var loginAction: CocoaAction = CocoaAction { Observable.empty() }
}
