//
//  TestableObserver+Ext.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 24.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import RxTest

extension TestableObserver {
    var lastElement: Element? {
        return events.last?.value.element
    }

    var firstElement: Element? {
        return events.first?.value.element
    }
}
