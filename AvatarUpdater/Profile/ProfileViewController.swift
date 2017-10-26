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
import Action
/// A type represnting a view model for `ProfileViewController`
protocol ProfileViewModelType {
    /// User avatart image
    var userAvatar: Driver<UIImage> { get }
    /// User email address
    var userEmail: Driver<String> { get }
    /// Bindable sink for picked image
    var pickedImage: AnyObserver<UIImage> { get }
    /// Indicate whether uploading avatar is in progress
    var isLoading: Driver<Bool> { get }
}

class ProfileViewController: UIViewController {
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var email: UILabel!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

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
        viewModel.isLoading.drive(spinner.rx.isAnimating).disposed(by: bag)
        
        let tap = UITapGestureRecognizer()
        avatar.addGestureRecognizer(tap)

        func showImagePicker(from source: UIImagePickerControllerSourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.allowsEditing = false
            if case .camera = source {
                picker.cameraDevice = .front
                picker.cameraCaptureMode = .photo
            }
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }

        tap
            .rx.event
            .map {_ -> [UIAlertAction] in
                let library = UIAlertAction(title: "Photo Library", style: .default) {_ in showImagePicker(from: .photoLibrary)}
                let camera = UIAlertAction(title: "Front Camera", style: .default) {_ in showImagePicker(from: .camera)}
                camera.isEnabled = UIImagePickerController.isCameraDeviceAvailable(.front)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                return [library, camera, cancel]
            }
            .map {actions -> UIAlertController in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                actions.forEach { alert.addAction($0) }
                return alert
            }
            .subscribe(onNext: {[unowned self] alert in
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        viewModel.pickedImage.onNext(image)
        picker.dismiss(animated: true, completion: nil)
    }
}
