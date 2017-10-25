//
//  NewSessionEndpoint.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Foundation

struct NewSessionEndpoint: Endpoint {
    let email: String
    let password: String
    
    var path: String {
        return "session/new"
    }
    var method: HTTPMethod {
        return .POST
    }
    var parameters: [String : Any]? {
        return [
            "email": email,
            "password": password,
        ]
    }
    
    
    private struct Session: Decodable {
        let user_id: String
        let token: String
    }
    
    func parse(_ data: Data) throws -> (userId: String, token: String) {
        let decoder = JSONDecoder()
        let response = try decoder.decode(Session.self, from: data)
        return (userId: response.user_id, token: response.token)
    }
}
