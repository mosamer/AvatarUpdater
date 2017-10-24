//
//  LoginViewController.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

/// A type representing a view model for `LoginViewController`
protocol LoginViewModelType {
    /// Bindable sink for user email input
    var email: AnyObserver<String> { get }
    /// Bindable sink for user password input
    var password: AnyObserver<String> { get }
    /// Login performable action
    var loginAction: CocoaAction { get }
}

class LoginViewController: UIViewController {

    private let viewModel: LoginViewModelType
    private let bag = DisposeBag()

    @IBOutlet private weak var email: UITextField!
    @IBOutlet private weak var password: UITextField!
    @IBOutlet private weak var login: UIButton!
    @IBOutlet private weak var loading: UIActivityIndicatorView!

    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "LoginViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: bag)
        password.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: bag)
        
        let action = viewModel.loginAction
        login.rx.action = action
        action.executing.bind(to: loading.rx.isAnimating).disposed(by: bag)
    }

}
