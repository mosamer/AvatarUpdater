//
//  APIClient.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift

class APIClient {
    static let instance = APIClient()
}

extension APIClient: LoginAPI {
    func login(email: String, password: String) -> Observable<String> {
        return Observable.empty()
    }
}
