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
import RxTest
@testable import AvatarUpdater

class LoginViewModelSpecs: QuickSpec {
    override func spec() {
        var sut: LoginViewModel!
        var scheduler: TestScheduler!
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            sut = LoginViewModel()
        }
        afterEach {
            sut = nil
            scheduler = nil
        }

        describe("Enable Login") {
            var enabled: TestableObserver<Bool>!
            beforeEach {
                enabled = scheduler.record(source: sut.loginAction.enabled)
            }
            afterEach {
                enabled = nil
            }
            func set(email: String = "user@email.com", password: String = "password") {
                scheduler.drive(sut.email, with: [next(0, email)])
                scheduler.drive(sut.password, with: [next(1, password)])
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
    }
}
