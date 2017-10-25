//
//  Helpers.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

struct AnyError: Swift.Error, Equatable {
    private let message: String
    init(_ message: String = "") {
        self.message = message
    }

    public static func ==(lhs: AnyError, rhs: AnyError) -> Bool {
        return lhs.message == rhs.message
    }
}
