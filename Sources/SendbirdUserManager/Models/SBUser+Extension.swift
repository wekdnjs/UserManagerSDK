//
//  SBUser.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation
extension SBUser: Decodable {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname = "nickname"
        case profileURL = "profile_url"
    }
    
    public init(from coder: Decoder) throws {
        let container = try coder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileURL = try container.decode(String.self, forKey: .profileURL)
    }
}
