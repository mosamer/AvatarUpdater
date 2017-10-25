//
//  TestScheduler+Ext.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxTest
import RxSwift

extension TestScheduler {
    /// Builds testable observer for s specific observable sequence, binds it's results and sets up disposal.
    ///
    /// - Parameter source: Observable sequence to observe.
    /// - Returns: Testable observer that records all events for observable sequence.
    func record<O: ObservableConvertibleType>(source: O) -> TestableObserver<O.E> {
        let observer = self.createObserver(O.E.self)
        let disposable = source.asObservable().subscribe(observer)
        self.scheduleAt(100000) {
            disposable.dispose()
        }
        return observer
    }

    /// Builds a hot observable with a predefines events, binds it's result to a specific observer and sets up disposal.
    ///
    /// - Parameters:
    ///   - target: Observer to bind to
    ///   - events: Array of recorded events to emit over the scheduled observable
    func drive<O: ObserverType>(_ target: O, with events: [Recorded<Event<O.E>>]) {
        let driver = self.createHotObservable(events)
        let disposable = driver.asObservable().subscribe(target)
        self.scheduleAt(100000) {
            disposable.dispose()
        }
    }
}
