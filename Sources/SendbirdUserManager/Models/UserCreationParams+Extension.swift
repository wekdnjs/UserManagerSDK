//
//  UserCreationParams+Extension.swift
//  
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

extension UserCreationParams {
    var params: [String: Any] {
        var dic = ["user_id": userId, "nickname": nickname]
        if let profileURL {
            dic["profile_url"] = profileURL
        }
        return dic
    }
}
