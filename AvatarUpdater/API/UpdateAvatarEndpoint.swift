//
//  UpdateAvatarEndpoint.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 26.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Foundation
import UIKit
struct UpdateAvatarEndpoint: Endpoint {
    let userId: String
    let avatar: UIImage
    private var encodedAvatar: String {
        guard let data = UIImageJPEGRepresentation(avatar, 1.0) else { return "" }
        return data.base64EncodedString()
    }
    var path: String { return "user/\(userId)/avatar" }
    var method: HTTPMethod { return .POST}
    var parameters: [String : Any]? { return ["avatar": encodedAvatar]}

    func parse(_ data: Data) throws -> URL {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
        guard let url = URL(string: json?["avatar_url"] ?? "") else { throw APIClient.Error.misformattedResponse }
        return url
    }
}
