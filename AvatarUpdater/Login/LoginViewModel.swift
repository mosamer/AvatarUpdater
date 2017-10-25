//
//  LoginViewModel.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift
import RxCocoa
import Action

/// A type representing API for login view model
protocol LoginAPI {
    /// Request user login
    ///
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Returns: Logged-in user ID.
    func login(email: String, password: String) -> Observable<String>
    /// Fetch user details
    ///
    /// - Parameter id: user Id
    /// - Returns: requested user profile details
    func user(id: String) -> Observable<User>
}

class LoginViewModel: LoginViewModelType {
    
    private let _email = PublishSubject<String>()
    private let _password = PublishSubject<String>()
    typealias Credintials = (email: String, password: String)
    private let loginAction: Action<Credintials, User>
    private let bag = DisposeBag()
    
    init(apiClient: LoginAPI,
         router: AnyObserver<Navigation>,
         userUpdater: @escaping (User) -> Void
        ) {
        loginAction = Action {
            apiClient
                .login(email: $0.email, password: $0.password)
                .flatMapLatest { apiClient.user(id: $0) }
        }
        
        let credentials = Observable.combineLatest(_email, _password) { (email: $0, password: $1) }
        _login
            .withLatestFrom(credentials)
            .bind(to: loginAction.inputs)
            .disposed(by: bag)
        
        loginAction
            .elements
            .do(onNext: userUpdater)
            .map { Navigation.profile(user: $0)}
            .bind(to: router)
            .disposed(by: bag)
    }
    
    var email: AnyObserver<String> {
        return _email.asObserver()
    }
    var password: AnyObserver<String> {
        return _password.asObserver()
    }
    private let _login = PublishSubject<Void>()
    var login: AnyObserver<Void> {
        return _login.asObserver()
    }
    
    var isLoginEnabled: Driver<Bool> {
        let validEmail = _email.map {
            $0.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                     options: .regularExpression) != nil
        }
        let validPassword = _password.map { $0.count >= 8 }
        
        return Observable
            .combineLatest(validEmail, validPassword) { $0 && $1 }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
    }
    var isLoading: Driver<Bool> {
        return loginAction.executing.asDriver(onErrorJustReturn: false)
    }
    var errorMessage: Driver<String> {
        let start = loginAction.inputs.map {_ in ""}
        let fail = loginAction
            .errors
            .map {error -> String in
                guard error.is(APIClient.Error.noResponse) else { return "Something went wrong. Try Again!" }
                return "Wrong email or password"
        }
        return Observable.merge([start, fail]).distinctUntilChanged().asDriver(onErrorJustReturn: "")
    }
}
