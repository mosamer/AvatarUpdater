//
//  AppDelegate.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private let bag = DisposeBag()
    
    enum NavigationEvent {
        case login
    }
    private let _router = PublishSubject<NavigationEvent>()
    
    var router: AnyObserver<NavigationEvent> {
        return _router.asObserver()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        let navigation = UINavigationController()
        navigation.setNavigationBarHidden(true, animated: false)
        
        _router
            .map {event -> UIViewController in
                switch event {
                case .login:
                    let loginViewModel = LoginViewModel(apiClient: APIClient.instance)
                    let loginViewController = LoginViewController(viewModel: loginViewModel)
                    return loginViewController
                }
        }
            .subscribe(onNext: {
                /* a hack to animate pushing, this is not a real router ¯\_(ツ)_/¯ */
                navigation.pushViewController($0, animated: true)
                navigation.setViewControllers([$0], animated: false)
            })
        .disposed(by: bag)
        
        self.window?.rootViewController = navigation
        
        _router.onNext(.login)
        return true
    }
    
    
    
}

