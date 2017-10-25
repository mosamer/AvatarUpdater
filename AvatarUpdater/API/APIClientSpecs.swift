//
//  APIClientSpecs.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest
@testable import AvatarUpdater

class APIClientSpecs: QuickSpec {
    override func spec() {
        var sut: APIClient!
        var scheduler: TestScheduler!
        var mockStore: MockTokenStore!
        var mockNetwork: MockNetworkService!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            mockStore = MockTokenStore(scheduler)
            mockNetwork = MockNetworkService(scheduler)
            sut = APIClient(network: mockNetwork, store: mockStore)
        }
        afterEach {
            sut = nil
            mockNetwork = nil
            mockStore = nil
            scheduler = nil
        }
        
        describe("Login") {
            describe("building request") {
                beforeEach {
                    _ = scheduler.record(source: sut.login(email: "user@email.com", password: "password"))
                }
                it("path") {
                    scheduler.start()
                    expect(mockNetwork).to(match(path: "session/new"))
                }
                it("method") {
                    scheduler.start()
                    expect(mockNetwork).to(match(method: .POST))
                }
                it("parameters") {
                    scheduler.start()
                    expect(mockNetwork).to(match(parameters: ["email": "user@email.com",
                                                              "password": "password",
                                                              ]))
                }
            }
            describe("parse response") {
                var response: TestableObserver<String>!
                beforeEach {
                    let data = try! JSONSerialization.data(withJSONObject: ["user_id": "1", "token": "abcdef"], options: .prettyPrinted)
                    mockNetwork.responseEvents = [next(0, data)]
                    response = scheduler.record(source: sut.login(email: "user@email.com", password: "password"))
                }
                afterEach {
                    response = nil
                }
                it("return user Id") {
                    scheduler.start()
                    expect(response.lastElement) == "1"
                }
                it("update user token") {
                    scheduler.start()
                    expect(mockStore.updatedToken) == "abcdef"
                }
            }
        }
    }
    
}
private func match(path expectedValue: String) -> Predicate<MockNetworkService> {
    return Predicate {exp in
        let request = try exp.evaluate()?.sentRequest
        let actualPath = request?.url?.absoluteString
        return PredicateResult(bool: actualPath == "http://localhost:3000/\(expectedValue)",
            message: .expectedActualValueTo(expectedValue))
    }
}
private func match(method expectedValue: HTTPMethod) -> Predicate<MockNetworkService> {
    return Predicate {exp in
        let request = try exp.evaluate()?.sentRequest
        let actualMethod = request?.httpMethod
        return PredicateResult(bool: actualMethod == expectedValue.rawValue,
                               message: .expectedActualValueTo(expectedValue.rawValue))
    }
}
private func match(parameters expectedValue: [String: Any]?) -> Predicate<MockNetworkService> {
    return Predicate {exp in
        let request = try exp.evaluate()?.sentRequest
        guard let data = request?.httpBody else {
            return PredicateResult(bool: expectedValue == nil, message: .expectedActualValueTo("nil"))
        }
        let actualParameters = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
        return PredicateResult(bool: actualParameters?.isEqual(to: expectedValue ?? [:]) ?? false,
                               message: .expectedActualValueTo(""))
    }
}

private class MockTokenStore: TokenStore {
    private let scheduler: TestScheduler
    init(_ scheduler: TestScheduler) {
        self.scheduler = scheduler
    }
    
    var token: String?
    var updatedToken: String?
    func update(token: String) {
        updatedToken = token
    }
}

private class MockNetworkService: NetworkService {
    private let scheduler: TestScheduler
    init(_ scheduler: TestScheduler) {
        self.scheduler = scheduler
    }
    
    var responseEvents: [Recorded<Event<Data>>] = []
    var sentRequest: URLRequest?
    func request(_ request: URLRequest) -> Observable<Data> {
        sentRequest = request
        return scheduler.createColdObservable(responseEvents).asObservable()
    }
}
