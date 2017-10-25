//
//  Helpers.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//
@testable import AvatarUpdater

struct AnyError: Swift.Error, Equatable {
    private let message: String
    init(_ message: String = "") {
        self.message = message
    }
    
    public static func ==(lhs: AnyError, rhs: AnyError) -> Bool {
        return lhs.message == rhs.message
    }
}

extension User: Equatable {
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
            lhs.email == rhs.email &&
            lhs.avatarURL == rhs.avatarURL
    }
}

