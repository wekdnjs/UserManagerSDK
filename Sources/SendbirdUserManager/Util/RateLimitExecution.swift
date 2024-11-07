//
//  RateLimitExecution.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

class RateLimitExecution {
    private var previousExecution = Date.distantPast
    private let lock = NSLock()
    
    func execute(interval: TimeInterval, queue: DispatchQueue, _ block: @escaping () -> Void) throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard abs(previousExecution.timeIntervalSinceNow) >= interval else {
            throw NetworkClientError.rateLimit
        }
        previousExecution = Date()
        queue.async {
            block()
        }
    }
}

class LocalRateLimitExecution {
    private let queue = Queue<RateLimitTask>()
    private let maxTaskCount: Int
    private let dispatchQueue: DispatchQueue
    private let timeInterval: TimeInterval
    private var timerQueue = DispatchQueue(label: "rate_limit_timer")
    
    init(maxTaskCount: Int, timeInteval: TimeInterval, dispatchQueue: DispatchQueue = .global(qos: .userInitiated)) {
        self.maxTaskCount = maxTaskCount
        self.timeInterval = timeInteval
        self.dispatchQueue = dispatchQueue
    }
    
    func add(task: RateLimitTask) -> Bool {
        guard queue.count < maxTaskCount else {
            return false
        }
        queue.enqueue(element: task)
        if queue.count == 1 {
            runAfterDelay()
        }
        return true
    }
    
    func removeAll() {
        self.queue.removeAll()
    }
    
    private func taskRun() {
        if let task = queue.peek() {
            dispatchQueue.async { [weak self] in
                task.executeBlock()
                self?.taskDone()
            }
        }
    }
    
    private func taskDone() {
        let _ = queue.dequeue()
        if queue.count > 0 {
          runAfterDelay()
        }
    }
    
    private func runAfterDelay() {
        timerQueue.asyncAfter(deadline: .now() + timeInterval, execute: { [weak self] in
            self?.taskRun()
        })
    }
}
