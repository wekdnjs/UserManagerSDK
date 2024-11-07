//
//  MockNetworkClient.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation
@testable import SendbirdUserManager

class MockNetworkClient: SBNetworkClient {
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : SendbirdUserManager.Request {
        if let request = request as? UserRequest<SBUser> {
            let stubUserId = request.parameters?["user_id"] as? String ?? ""
            let stubNickname = request.parameters?["nickname"] as? String ?? ""
            let stubUser = SBUser(userId: stubUserId, nickname: stubNickname)
            completionHandler(.success(stubUser as! R.Response))
            return
        }
        completionHandler(.failure(HttpApiError.sbApiError(404, nil)))
        
    }
}
