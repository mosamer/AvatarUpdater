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
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var email: UILabel!
    
    private let viewModel: ProfileViewModelType
    init(viewModel: ProfileViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatar.layer.cornerRadius = avatar.bounds.width / 2.0
        avatar.layer.borderColor = UIColor.darkGray.cgColor
        avatar.layer.borderWidth = 3.0
        avatar.layer.masksToBounds = true
    }

}
