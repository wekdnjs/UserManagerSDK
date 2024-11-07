//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation

public protocol Request {
    associatedtype Response: Decodable
    var url: URL { get }
    var method: String { get }
    var header: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

public protocol SBNetworkClient {
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}
