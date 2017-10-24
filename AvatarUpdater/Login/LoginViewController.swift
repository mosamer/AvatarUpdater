//
//  LoginViewController.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import UIKit

/// A type representing a view model for `LoginViewController`
protocol LoginViewModelType {

}

class LoginViewController: UIViewController {

    private let viewModel: LoginViewModelType
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "LoginViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
