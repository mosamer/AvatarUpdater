//
//  ProfileViewModelSpecs.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
@testable import AvatarUpdater

class ProfileViewModelSpecs: QuickSpec {
    override func spec() {
        var sut: ProfileViewModel!
        var scheduler: TestScheduler!
        var mockAPI: MockProfileAPI!
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            mockAPI = MockProfileAPI(scheduler)
        }
        afterEach {
            sut = nil
            mockAPI = nil
            sut = nil
        }

        describe("email address") {
            it("show email address") {
                sut = ProfileViewModel(user: User(email: "foo@bar.com"), api: mockAPI)
                SharingScheduler.mock(scheduler: scheduler) {
                    let email = scheduler.record(source: sut.userEmail)
                    scheduler.start()
                    expect(email.firstElement) == "foo@bar.com"
                }
            }
        }
    }

    private class MockProfileAPI: ProfileAPI {
        private let scheduler: TestScheduler
        init(_ scheduler: TestScheduler) {
            self.scheduler = scheduler
        }

        func image(from url: URL) -> Observable<UIImage> {
            return Observable.empty()
        }
    }
}
