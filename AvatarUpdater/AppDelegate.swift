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

typealias Navigation = AppDelegate.NavigationEvent
typealias UserUpdater = (User) -> Void
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private let bag = DisposeBag()
    
    enum NavigationEvent {
        case login
        case profile(user: User)
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
        
        let userKey = "com.mosamer.AvatarUpdater:User"
        let userUpdater: (User) -> Void = {
            let encoder = JSONEncoder()
            let data = try? encoder.encode($0)
            UserDefaults.standard.set(data, forKey: userKey)
            UserDefaults.standard.synchronize()
        }
        _router
            .observeOn(MainScheduler.instance)
            .map {event -> UIViewController in
                switch event {
                case .login:
                    let loginViewModel = LoginViewModel(
                        apiClient: APIClient.instance,
                        router: self.router,
                        userUpdater: userUpdater)
                    let loginViewController = LoginViewController(viewModel: loginViewModel)
                    return loginViewController
                case .profile(let user):
                    let profileViewModel = ProfileViewModel(user: user,
                                                            api: APIClient.instance)
                    let profileViewController = ProfileViewController(viewModel: profileViewModel)
                    return profileViewController
                }
            }
            .subscribe(onNext: {
                /* a hack to animate pushing, this is not a real router ¯\_(ツ)_/¯ */
                navigation.pushViewController($0, animated: true)
                navigation.setViewControllers([$0], animated: false)
            })
            .disposed(by: bag)
        
        self.window?.rootViewController = navigation
        
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: userKey),
            let user = try? decoder.decode(User.self, from: data) {
            _router.onNext(.profile(user: user))
        } else {
            _router.onNext(.login)
        }
        return true
    }
    
    
    
}

