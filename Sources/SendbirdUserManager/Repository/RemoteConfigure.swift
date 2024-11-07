//
//  File.swift
//  
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

class RemoteConfigure {
    var appID: String?
    private var host: String {
        "https://api-\(appID ?? "").sendbird.com/v3"
    }
    
    enum PathType {
        case createUser
        case createUsers
        case getUser(id: String)
        case getUsers
        case updateUser(id: String)
        var path: String {
            switch self {
            case .createUser, .createUsers, .getUsers:
                return "/users"
            case .getUser(let userID), .updateUser(let userID):
                return "/users/\(userID)"
            }
        }
    }
   
    func url(pathType: PathType) -> String {
        return host + pathType.path
    }
}
