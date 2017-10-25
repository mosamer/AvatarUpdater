//
//  LoginViewModelSpecs.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
import Action
@testable import AvatarUpdater

class LoginViewModelSpecs: QuickSpec {
    override func spec() {
        var sut: LoginViewModel!
        var mockAPI: MockLoginAPI!
        var scheduler: TestScheduler!
        var router: TestableObserver<AppDelegate.NavigationEvent>!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            mockAPI = MockLoginAPI(scheduler)
            router = scheduler.createObserver(Navigation.self)
            sut = LoginViewModel(apiClient: mockAPI, router: router.asObserver())
        }
        afterEach {
            sut = nil
            mockAPI = nil
            scheduler = nil
        }

        func set(email: String = "user@email.com", password: String = "password") {
            scheduler.drive(sut.email, with: [next(0, email)])
            scheduler.drive(sut.password, with: [next(1, password)])
        }

        describe("Enable Login") {
            var enabled: TestableObserver<Bool>!
            beforeEach {
                SharingScheduler.mock(scheduler: scheduler) {
                    enabled = scheduler.record(source: sut.isLoginEnabled)
                }
            }
            afterEach {
                enabled = nil
            }
            it("disable login, initially") {
                scheduler.start()
                expect(enabled.firstElement) == false
            }
            it("disable login, if email is not valid") {
                set(email: "invalid.email")
                scheduler.start()
                expect(enabled.lastElement) == false
            }

            it("disable login, if password is less than 8 chars") {
                set(password: "foo")
                scheduler.start()
                expect(enabled.lastElement) == false
            }
            it("enable login, if email & password are valid") {
                set(email: "user@email.com", password: "password")
                scheduler.start()
                expect(enabled.lastElement) == true
            }
        }
        
        describe("API call") {
            it("call api with user email and password") {
                set(email: "user@email.com", password: "password")
                scheduler.drive(sut.login, with: [next(5, ())])
                scheduler.start()
                expect(mockAPI.userEmail) == "user@email.com"
                expect(mockAPI.userPassword) == "password"
            }
            it("call api with returned user ID") {
                set(email: "user@email.com", password: "password")
                mockAPI.loginEvents = [next(0, "user-id")]
                scheduler.drive(sut.login, with: [next(5, ())])
                scheduler.start()
                expect(mockAPI.queriedUser) == "user-id"
            }
        }
        describe("Error messages") {
            var message: TestableObserver<String>!
            beforeEach {
                set(email: "user@email.com", password: "password")
                SharingScheduler.mock(scheduler: scheduler) {
                    message = scheduler.record(source: sut.errorMessage)
                }
            }
            it("show wrong credintials, if no response") {
                mockAPI.loginEvents = [error(0, APIClient.Error.noResponse)]
                scheduler.drive(sut.login, with: [next(5, ())])
                scheduler.start()
                expect(message.lastElement) == "Wrong email or password"
            }
            it("show generic message, if any other error") {
                mockAPI.loginEvents = [error(0, APIClient.Error.misformattedResponse)]
                scheduler.drive(sut.login, with: [next(5, ())])
                scheduler.start()
                expect(message.lastElement) == "Something went wrong. Try Again!"
            }
            it("show none, when new request start") {
                mockAPI.loginEvents = []
                mockAPI.userEvents = []
                scheduler.drive(sut.login, with: [next(5, ())])
                scheduler.start()
                expect(message.lastElement) == ""
            }
        }
        it("navigate to profile with logged in user") {
            let user = User(id: "user-id", email: "user@email.com", avatarURL: nil)
            mockAPI.loginEvents = [next(0, "")]
            mockAPI.userEvents = [next(0, user)]
            set(email: "user@email.com", password: "password")
            scheduler.drive(sut.login, with: [next(5, ())])
            scheduler.start()
            expect(router.lastElement) == Navigation.profile(user: user)
        }
    }
    
    private class MockLoginAPI: LoginAPI {
        private let scheduler: TestScheduler
        init(_ scheduler: TestScheduler) {
            self.scheduler = scheduler
        }
        
        var userEmail: String?
        var userPassword: String?
        var loginEvents: [Recorded<Event<String>>] = []
        func login(email: String, password: String) -> Observable<String> {
            userEmail = email
            userPassword = password
            return scheduler.createColdObservable(loginEvents).asObservable()
        }
        
        var queriedUser: String?
        var userEvents: [Recorded<Event<User>>] = []
        func user(id: String) -> Observable<User> {
            queriedUser = id
            return scheduler.createColdObservable(userEvents).asObservable()
        }
    }
}
