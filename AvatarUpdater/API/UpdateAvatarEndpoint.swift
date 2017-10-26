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
        let maxSize = 45 * 1024 /* this value is based on trial-and-error, 1MB keep failing */
        var data = Data(count: maxSize + 1)
        var quality: CGFloat = 1.0
        while data.count > maxSize && quality > 0.0001 {
            data = UIImageJPEGRepresentation(avatar, quality) ?? Data()
            quality *= 0.7
        }
        return data.base64EncodedString()
    }
    var path: String { return "user/\(userId)/avatar" }
    var method: HTTPMethod { return .POST}
    var parameters: [String : Any]? { return ["avatar": encodedAvatar] }

    func parse(_ data: Data) throws -> URL {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
        guard let url = URL(string: json?["avatar_url"] ?? "") else { throw APIClient.Error.misformattedResponse }
        return url
    }
}
