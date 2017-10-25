//
//  Helpers.swift
//  AvatarUpdaterTests
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Foundation
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
    init(id: String = "user-id",
         email: String = "user@email.com",
         avatarURL: URL? = nil) {
        self.id = id
        self.email = email
        self.avatarURL = avatarURL
    }
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
            lhs.email == rhs.email &&
            lhs.avatarURL == rhs.avatarURL
    }
}

extension Navigation: Equatable {
    public static func ==(lhs: Navigation, rhs: Navigation) -> Bool {
        switch (lhs, rhs) {
        case (.login, .login):
            return true
        case let (.profile(user1), .profile(user2)):
            return user1 == user2
        default:
            return false
        }
    }
}
