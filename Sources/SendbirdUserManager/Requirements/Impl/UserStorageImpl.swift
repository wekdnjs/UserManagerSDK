//
//  UserStorage.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation
import CoreData

public class UserStorage: SBUserStorage {
    class Users {
        var sbUsers: [SBUser]
        init(_ sbUsers: [SBUser]) {
            self.sbUsers = sbUsers
        }
    }
    private let cache = NSCache<NSString, Users>()
    private let usersCacheKey: NSString = "users_cache_key"
    private let lock = NSLock()
    public init() {
        cache.totalCostLimit = 5 * 1024 * 1024 //5MB
    }
    
    public func upsertUser(_ user: SBUser) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if let cachedUsers = cache.object(forKey: usersCacheKey) {
            var sbUsers = cachedUsers.sbUsers
            if let storedUserIndex = sbUsers.firstIndex(where: { $0.userId == user.userId}) {
                sbUsers[storedUserIndex] = user
            } else {
                sbUsers.append(user)
            }
            cache.setObject(Users(sbUsers), forKey: usersCacheKey)
        } else {
            cache.setObject(Users([user]), forKey: usersCacheKey)
        }
    }
    
    public func getUsers() -> [SBUser] {
        lock.lock()
        defer {
            lock.unlock()
        }
        if let cachedUsers = cache.object(forKey: usersCacheKey) {
            return cachedUsers.sbUsers
        } else {
            return []
        }
    }
    
    public func getUsers(for nickname: String) -> [SBUser] {
        return getUsers().filter { $0.nickname == nickname }
    }
    
    public func getUser(for userId: String) -> (SBUser)? {
        return getUsers().first { $0.userId == userId }
    }
    
    public func removeAllUsers() {
        cache.removeAllObjects()
    }
}


