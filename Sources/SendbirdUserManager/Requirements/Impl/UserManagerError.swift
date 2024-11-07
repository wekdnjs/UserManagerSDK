//
//  UserManagerError.swift
//  
//
//  Created by 윤다원 on 11/6/24.
//

import Foundation

public enum UserManagerError: LocalizedError {
    case notInitialized
    case unexpectedRelease
    case badURL
    case createUsersFail(success: [SBUser], fail: [UserCreationParams])
    case requestsExceeded
    case nicknameMatchesEmpty
    case userIdEmpty
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "call initApplication when the app launched"
        case .unexpectedRelease:
            return "maintain a reference to the UserManager instance"
        case .badURL:
            return "bad url. check the applicationId"
        case .createUsersFail:
            return "failed to create one or more. check failed user list"
        case .requestsExceeded:
            return "requests exceeding 10 are limited."
        case .nicknameMatchesEmpty:
            return "nicknameMatches must not be empty"
        case .userIdEmpty:
            return "userId must not be empty"
        }
    }
}

public enum NetworkClientError: LocalizedError {
    case rateLimit
    public var errorDescription: String? {
        switch self {
        case.rateLimit:
            return "try at least 1 second later than the previous request"
        }
    }
}
