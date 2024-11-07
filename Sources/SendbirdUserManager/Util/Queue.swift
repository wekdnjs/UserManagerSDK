//
//  Queue.swift
//
//
//  Created by 윤다원 on 11/6/24.
//

import Foundation
final class Queue<T> {
    private var array: [T] = []
    private let lock: NSLock = NSLock()
    
    var count: Int {
        lock.lock()
        defer {
            lock.unlock()
        }
        return array.count
    }
    
    func enqueue(element: T) {
        lock.lock()
        defer {
            lock.unlock()
        }
        array.append(element)
    }
    
    func dequeue() -> T? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return array.count > 0 ? array.remove(at: 0): nil
    }
    
    func peek() -> T? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return array.first
    }
    
    func removeAll() {
        lock.lock()
        defer {
            lock.unlock()
        }
        array.removeAll()
    }
}
