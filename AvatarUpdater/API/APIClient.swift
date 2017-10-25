
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
/// HTTP method
///
/// - GET: GET request
/// - POST: POST request
enum HTTPMethod: String {
    case GET, POST
}

/// A type representing an API endpoint.
///
/// Endpoint provides 1-to-1 mapping with API endpoints defining required attributes to setup `URLRequest` and how to parse response
protocol Endpoint {
    /// Response type
    associatedtype Response
    /// URL path
    var path: String { get }
    /// HTTP method
    var method: HTTPMethod { get }
    /// request parameters if any
    var parameters: [String: Any]? { get }
    /// Parse returned response data into defined response type
    ///
    /// - Parameter data: URL response data
    /// - Returns: Parsed response object
    /// - Throws: noResponse, if no data was returned
    /// - Throws: misformattedResponse, if unable to parse returned JSON
    func parse(_ data: Data) throws -> Response
}

class APIClient {
    enum Error: Swift.Error {
        case noResponse
        case misformattedResponse
    }
    
    static let instance = APIClient(network: URLSession.shared,
                                    store: UserDefaults.standard)
    private static let baseURL = URL(string: "http://localhost:3000")!
    
    private let network: NetworkService
    private let store: TokenStore
    
    init(network: NetworkService, store: TokenStore) {
        self.network = network
        self.store = store
    }
    
    private func request<E: Endpoint>(_ endpoint: E) -> Observable<E.Response> {
        return Observable
            .deferred { () -> Observable<URLRequest> in
                var request = URLRequest(url: APIClient.baseURL.appendingPathComponent(endpoint.path))
                request.httpMethod = endpoint.method.rawValue
                request.httpBody = try JSONSerialization.data(withJSONObject: endpoint.parameters ?? [:],
                                                              options: .prettyPrinted)
                return Observable.of(request)
            }
            .flatMap {[unowned self] in
                self.network.request($0)
            }
            .map {data -> E.Response in
                guard data.count > 0 else { throw Error.noResponse }
                return try endpoint.parse(data)
        }
    }
}

extension APIClient: LoginAPI {
    func login(email: String, password: String) -> Observable<String> {
        let endpoint = NewSessionEndpoint(email: email, password: password)
        return self.request(endpoint)
            .do(onNext: {[unowned self] in
                self.store.update(token: $0.token)
            })
            .map { $0.userId }
    }
    
    func user(id: String) -> Observable<User> {
        return Observable.empty()
    }
}
