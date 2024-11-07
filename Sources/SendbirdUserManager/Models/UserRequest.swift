//
//  UserRequest.swift
//  
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

struct UserRequest<T: Decodable>: Request {
    typealias Response = T
    var url: URL
    var method: String
    var header: [String: String]?
    var parameters: [String: Any]?
}

