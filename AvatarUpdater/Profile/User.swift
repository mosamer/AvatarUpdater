//
//  User.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let avatarURL: URL?

    func updatingAvatarURL(_ newURL: URL?) -> User {
        return User(id: self.id,
                    email: self.email,
                    avatarURL: newURL)
    }
}
