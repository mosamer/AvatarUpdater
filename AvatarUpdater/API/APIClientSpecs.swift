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
        
        sharedExamples("endpoint error handling") {aClosure in
            var call: (() -> Observable<Void>)!
            beforeEach {
                call = aClosure()["api-call"] as! (() -> Observable<Void>)
            }
            afterEach {
                call = nil
            }
            it("error if no response") {
                mockNetwork.responseEvents = [next(0, Data())]
                let response = scheduler.record(source: call())
                scheduler.start()
                let error = response.events.first?.value.error
                expect(error).to(matchError(APIClient.Error.noResponse))
            }
            it("error, if misformatted response") {
                let data = try! JSONSerialization.data(withJSONObject: ["foo": "bar"], options: .prettyPrinted)
                mockNetwork.responseEvents = [next(0, data)]
                let response = scheduler.record(source: call())
                scheduler.start()
                let error = response.events.first?.value.error
                expect(error).to(matchError(APIClient.Error.misformattedResponse))
            }
            it("error, if network error") {
                mockNetwork.responseEvents = [error(0, AnyError("network-error"))]
                let response = scheduler.record(source: call())
                scheduler.start()
                let _error = response.events.first?.value.error
                expect(_error).to(matchError(AnyError("network-error")))
            }
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
            
            itBehavesLike("endpoint error handling") {
                let loginCall: () -> Observable<Void> = { sut.login(email: "user@email.com", password: "password").map {_ in} }
                return ["api-call": loginCall]
            }
        }
        describe("User Details") {
            describe("building request") {
                beforeEach {
                    mockStore.token = "any-token"
                    _ = scheduler.record(source: sut.user(id: "user-id"))
                }
                it("path") {
                    scheduler.start()
                    expect(mockNetwork).to(match(path: "user/user-id"))
                }
                it("method") {
                    scheduler.start()
                    expect(mockNetwork).to(match(method: .GET))
                }
                it("parameters") {
                    scheduler.start()
                    expect(mockNetwork).to(match(parameters: nil))
                }
                it("bearer") {
                    scheduler.start()
                    expect(mockNetwork).to(match(token: "any-token"))
                }
            }
            describe("parse response") {
                var response: TestableObserver<User>!
                beforeEach {
                    let data = try! JSONSerialization.data(withJSONObject: ["email": "foo@bar.com",
                        "avatar_url": "http://localhost:3000/avatar.png"], options: .prettyPrinted)
                    mockNetwork.responseEvents = [next(0, data)]
                    response = scheduler.record(source: sut.user(id: "user-id"))
                }
                afterEach {
                    response = nil
                }
                it("parse correct user") {
                    scheduler.start()
                    expect(response.lastElement) == User(id: "user-id",
                                                         email: "foo@bar.com",
                                                         avatarURL: URL(string: "http://localhost:3000/avatar.png"))
                }
                itBehavesLike("endpoint error handling") {
                    let userCall: () -> Observable<Void> = { sut.user(id: "user-id").map {_ in} }
                    return ["api-call": userCall]
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
        guard let expectedParameters = expectedValue else {
            return PredicateResult(bool: false, message: .fail("expected no params"))
        }
        
        return PredicateResult(bool: actualParameters?.isEqual(to: expectedParameters) ?? false,
                               message: .expectedActualValueTo(""))
    }
}
private func match(token expectedToken: String?) -> Predicate<MockNetworkService> {
    return Predicate {exp in
        let request = try exp.evaluate()?.sentRequest
        let actualToken = request?.allHTTPHeaderFields?["Bearer"]
        return PredicateResult(bool: actualToken == expectedToken,
                               message: .expectedActualValueTo(expectedToken ?? ""))
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
