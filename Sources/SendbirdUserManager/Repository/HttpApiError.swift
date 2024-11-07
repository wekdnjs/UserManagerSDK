//
//  HttpApiError.swift
//
//
//  Created by 윤다원 on 11/6/24.
//

import Foundation

enum HttpApiError: Error {
    case emptyData
    case decodeError
    case sbApiError(_ statusCode: Int, _ info: HTTPErrorInfo?)
}

struct HTTPErrorInfo: Decodable {
    var error: Bool
    var code: Int
    var message: String
}
