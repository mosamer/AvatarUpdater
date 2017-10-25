//
//  ProfileViewController.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
/// A type represnting a view model for `ProfileViewController`
protocol ProfileViewModelType {
    /// User avatart image
    var userAvatar: Driver<UIImage> { get }
    /// User email address
    var userEmail: Driver<String> { get }
}

class ProfileViewController: UIViewController {
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var email: UILabel!
    
    private let viewModel: ProfileViewModelType
    private let bag = DisposeBag()
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

        viewModel.userAvatar.drive(avatar.rx.image).disposed(by: bag)
        viewModel.userEmail.drive(email.rx.text).disposed(by: bag)
    }

}
