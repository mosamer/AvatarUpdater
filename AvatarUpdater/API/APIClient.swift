//
//  APIClient.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxSwift

//MARK:- Token Store
/// A type representing a store to retrieve and update user token
protocol TokenStore {
    /// User token, nil if none was saved
    var token: String? { get }
    /// Update user token with new value
    ///
    /// - Parameter token: user token
    func update(token: String)
}

extension UserDefaults: TokenStore {
    private static let tokenKey = "com.mosamer.AvatarUpdater:UserToken"
    var token: String? {
        return string(forKey: UserDefaults.tokenKey)
    }
    func update(token: String) {
        set(token, forKey: UserDefaults.tokenKey)
        synchronize()
    }
}

//MARK:- Network Service
/// A type represents a network service provider for API client
protocol NetworkService {
    /// Send URL request
    ///
    /// - Parameter request: a request
    /// - Returns: response data
    func request(_ request: URLRequest) -> Observable<Data>
}

extension URLSession: NetworkService {
    func request(_ request: URLRequest) -> Observable<Data> {
        return rx.data(request: request)
    }
}

//MARK:- APIClient
class APIClient {
    static let instance = APIClient(network: URLSession.shared,
                                    store: UserDefaults.standard)

    init(network: NetworkService, store: TokenStore) {

    }
}

extension APIClient: LoginAPI {
    func login(email: String, password: String) -> Observable<String> {
        return Observable.empty()
    }
}
