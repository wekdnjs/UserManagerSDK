//
//  UserUpdateParams+Extension.swift
//  
//
//  Created by 윤다원 on 11/6/24.
//

import Foundation

extension UserUpdateParams {
    var params: [String: Any] {
        return ["nickname": nickname ?? "", "profile_url": profileURL ?? ""]
    }
}
