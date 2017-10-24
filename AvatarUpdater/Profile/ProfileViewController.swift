//
//  ProfileViewController.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import UIKit

/// A type represnting a view model for `ProfileViewController`
protocol ProfileViewModelType {

}

class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModelType
    init(viewModel: ProfileViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
