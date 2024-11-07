//
//  RateLimitTask.swift
//
//
//  Created by 윤다원 on 11/7/24.
//

import Foundation

struct RateLimitTask {
    private let request: any Request
    private let block: ((any Request) -> Void)?
    
    init(request: any Request, block: ((any Request) -> Void)?) {
        self.request = request
        self.block = block
    }
    
    func executeBlock() {
        block?(request)
    }
}
