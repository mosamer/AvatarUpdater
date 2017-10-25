//
//  UserEndpoint.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Foundation

struct UserEndpoint: Endpoint {
    let userId: String
    
    var path: String { return "user/\(userId)"}
    var method: HTTPMethod { return .GET }
    var parameters: [String : Any]? { return nil }
    
    func parse(_ data: Data) throws -> User {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
        
        guard let email = json?["email"] else { throw APIClient.Error.misformattedResponse }
        return User(id: userId,
                    email: email,
                    avatarURL: URL(string: json?["avatar_url"] ?? ""))
    }
}
