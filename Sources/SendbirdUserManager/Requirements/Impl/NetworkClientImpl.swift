//
//  NetworkClientImpl.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

public class NetworkClient: SBNetworkClient, RemoteProtocol {
    private let rateLimitExecution = RateLimitExecution()
    
    public init() {}
    
    public func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        do {
            try rateLimitExecution.execute(interval: 1, queue: .global(qos: .userInitiated)) { [weak self] in
                guard let self else { return }
                self.requestAndDecode(url: request.url, parameters: request.parameters, headerFields: request.header, method: request.method, completionHandler: completionHandler)
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
}

