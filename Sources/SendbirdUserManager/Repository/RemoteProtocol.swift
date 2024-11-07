//
//  RemoteProtocol.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

protocol RemoteProtocol {
    func requestAndDecode<T: Decodable>(url: URL, parameters: [String: Any]?, headerFields: [String: String]?, method: String, completionHandler: @escaping (Result<T, any Error>) -> Void)
}

extension RemoteProtocol {
    func requestAndDecode<T: Decodable>(url: URL, parameters: [String: Any]? = nil, headerFields: [String: String]? = nil, method: String = "GET", completionHandler: @escaping (Result<T, any Error>) -> Void) {
         
        // URLSession
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        
        let session = URLSession(configuration: configuration)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        //parameters
        if let parameters {
            if method == "GET" {
                var components = URLComponents(string: url.absoluteString)
                components?.queryItems = parameters.map { key, value in
                    return URLQueryItem(name: key, value: value as? String)
                }
                if let url = components?.url {
                    request = URLRequest(url: url)
                }
            } else {
                let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
            }
        }
        
        //headerFields
        if let headerFields {
            headerFields.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
      
        //task
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let data else {
                completionHandler(.failure(HttpApiError.emptyData))
                return
            }
           
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let cachedResponse = CachedURLResponse(response: httpResponse, data: data, storagePolicy: .allowedInMemoryOnly)
                    URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                    
                    do {
                        let decodeObject = try JSONDecoder().decode(T.self, from: data)
                        completionHandler(.success(decodeObject))
                        return
                    } catch {
                        completionHandler(.failure(HttpApiError.decodeError))
                        return
                    }
                } else {
                    let errorInfo = try? JSONDecoder().decode(HTTPErrorInfo.self, from: data)
                    completionHandler(.failure(HttpApiError.sbApiError(httpResponse.statusCode, errorInfo)))
                    return
                }
            }
        }
        task.resume()
    }
}
