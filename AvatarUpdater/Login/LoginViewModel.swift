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

    private let _email = PublishSubject<String>()
    private let _password = PublishSubject<String>()

    lazy var loginAction: CocoaAction = {
        let validEmail = _email.map {
            $0.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                     options: .regularExpression) != nil
        }
        let validPassword = _password.map { $0.count >= 8 }

        let enabled = Observable.combineLatest(validEmail, validPassword) { $0 && $1 }

        return CocoaAction(enabledIf: enabled) {
            return Observable.empty()
        }
    }()

    var email: AnyObserver<String> {
        return _email.asObserver()
    }
    var password: AnyObserver<String> {
        return _password.asObserver()
    }
}
