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
        describe("avatar image") {
            var image: TestableObserver<UIImage>!
            afterEach {
                image = nil
            }

            it("do not fetch, if url is nil") {
                sut = ProfileViewModel(user: User(), api: mockAPI)
                SharingScheduler.mock(scheduler: scheduler) {
                    image = scheduler.record(source: sut.userAvatar)
                }
                scheduler.start()
                expect(image.firstElement) == #imageLiteral(resourceName: "default_avatar")
                expect(mockAPI.imageURL).to(beNil())
            }
            it("fetch image from API") {
                let url = "http://localhost:3000/avatar.png"
                mockAPI.imageEvents = [next(0, #imageLiteral(resourceName: "alt_default_avatar"))]
                sut = ProfileViewModel(user: User(avatarURL: URL(string: url)), api: mockAPI)
                SharingScheduler.mock(scheduler: scheduler) {
                    image = scheduler.record(source: sut.userAvatar)
                }
                scheduler.start()
                expect(image.firstElement) == #imageLiteral(resourceName: "alt_default_avatar")
                expect(mockAPI.imageURL) == url
            }
            it("show default, if error while fetching from API") {
                let url = "http://localhost:3000/avatar.png"
                mockAPI.imageEvents = [error(0, AnyError())]
                sut = ProfileViewModel(user: User(avatarURL: URL(string: url)), api: mockAPI)
                SharingScheduler.mock(scheduler: scheduler) {
                    image = scheduler.record(source: sut.userAvatar)
                }
                scheduler.start()
                expect(image.firstElement) == #imageLiteral(resourceName: "default_avatar")
                expect(mockAPI.imageURL) == url
            }
        }
    }

    private class MockProfileAPI: ProfileAPI {
        private let scheduler: TestScheduler
        init(_ scheduler: TestScheduler) {
            self.scheduler = scheduler
        }

        var imageURL: String?
        var imageEvents: [Recorded<Event<UIImage>>] = []
        func image(from url: URL) -> Observable<UIImage> {
            self.imageURL = url.absoluteString
            return scheduler.createColdObservable(imageEvents).asObservable()
        }
    }
}