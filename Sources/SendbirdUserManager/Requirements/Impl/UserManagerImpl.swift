//
//  UserManagerImpl.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation
import CoreData

public class UserManager: SBUserManager {
    public let networkClient: SBNetworkClient
    public let userStorage: SBUserStorage
    
    private let remoteConfiguration = RemoteConfigure()
    private let localRateLimitExecution = LocalRateLimitExecution(maxTaskCount: 10, timeInteval: 1)
    private let appStorage: AppStorageProtoocol = AppStorage()
    
    private var applicationID: String?
    private var apiToken: String?
    
    public init(networkClient: SBNetworkClient, userStorage: SBUserStorage) {
        self.networkClient = networkClient
        self.userStorage = userStorage
    }
    
    deinit {
        localRateLimitExecution.removeAll()
    }
    
    public func initApplication(applicationId: String, apiToken: String) {
        if let storedAppID = appStorage.loadAppID(), storedAppID != applicationId {
           removeAllData()
        }
        
        self.applicationID = applicationId
        self.apiToken = apiToken
        
        self.appStorage.storeAppID(applicationId)
        self.remoteConfiguration.appID = applicationId
    }
    
    private func removeAllData() {
        userStorage.removeAllUsers()
        appStorage.removeAll()
        localRateLimitExecution.removeAll()
        URLCache.shared.removeAllCachedResponses()
    }
    
    public func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        guard let _ = applicationID , let apiToken else {
            completionHandler?(.failure(UserManagerError.notInitialized))
            return
        }
        
        guard let url = URL(string: remoteConfiguration.url(pathType: .createUser)) else {
            completionHandler?(.failure(UserManagerError.badURL))
            return
        }

        let request = UserRequest<SBUser>(url: url, method: "POST", header: ["Api-Token": apiToken], parameters: params.params)
        
        let rateLimitTask = RateLimitTask(request: request) { [weak self] request in
               guard let self, let request = request as? UserRequest<SBUser> else { return }
               self.networkClient.request(request: request) { [weak self] result in
                   guard let self else {
                       completionHandler?(.failure(UserManagerError.unexpectedRelease))
                       return
                   }
                   if case .success(let user) = result {
                       userStorage.upsertUser(user)
                   }
                   completionHandler?(result)
               }
        }
        
        if localRateLimitExecution.add(task: rateLimitTask) == false {
            completionHandler?(.failure(UserManagerError.requestsExceeded))
        }
    }
    
    public func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        guard params.count <= 10 else {
            completionHandler?(.failure(UserManagerError.requestsExceeded))
            return
        }
        
        guard params.isEmpty == false else {
            completionHandler?(.success([]))
            return
        }
        
        guard let _ = applicationID, let _ = apiToken else {
            completionHandler?(.failure(UserManagerError.notInitialized))
            return
        }
        
        
        var sucessUsers = [SBUser]()
        var failUsers = [UserCreationParams]()
        
        for param in params {
            createUser(params: param, completionHandler: { result in
                switch result {
                case.success(let user):
                    sucessUsers.append(user)
                case .failure:
                    failUsers.append(param)
                }
                if sucessUsers.count + failUsers.count == params.count {
                    if failUsers.isEmpty {
                        completionHandler?(.success(sucessUsers))
                    } else {
                        completionHandler?(.failure(UserManagerError.createUsersFail(success: sucessUsers, fail: failUsers)))
                    }
                }
            })
        }
    }
    
    public func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        guard let _ = applicationID, let apiToken else {
            completionHandler?(.failure(UserManagerError.notInitialized))
            return
        }
        
        guard let url = URL(string: remoteConfiguration.url(pathType: .updateUser(id: params.userId))) else {
            completionHandler?(.failure(UserManagerError.badURL))
            return
        }
        
        guard params.userId.isEmpty == false else {
            completionHandler?(.failure(UserManagerError.userIdEmpty))
            return
        }
        
        let request = UserRequest<SBUser>(url: url, method: "PUT", header: ["Api-Token": apiToken], parameters: params.params)
        
        networkClient.request(request: request) { [weak self] result in
            guard let self else {
                completionHandler?(.failure(UserManagerError.unexpectedRelease))
                return
            }
            
            if case .success(let user) = result {
                userStorage.upsertUser(user)
            }
            completionHandler?(result)
        }
    }
    
    public func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        guard let _ = applicationID, let apiToken else {
            completionHandler?(.failure(UserManagerError.notInitialized))
            return
        }
        
        guard userId.isEmpty == false else {
            completionHandler?(.failure(UserManagerError.userIdEmpty))
            return
        }
        
        if let user = userStorage.getUser(for: userId) {
            completionHandler?(.success(user))
            return
        }
        
        guard let url = URL(string: remoteConfiguration.url(pathType: .getUser(id: userId))) else {
            completionHandler?(.failure(UserManagerError.badURL))
            return
        }
        
        let request = UserRequest<SBUser>(url: url, method: "GET", header: ["Api-Token": apiToken], parameters: nil)
        
        networkClient.request(request: request) { [weak self] result in
            guard let self else {
                completionHandler?(.failure(UserManagerError.unexpectedRelease))
                return
            }
            
            if case .success(let user) = result {
                userStorage.upsertUser(user)
            }
            
            completionHandler?(result)
        }
    }
    
    public func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        guard nicknameMatches.isEmpty == false else {
            completionHandler?(.failure(UserManagerError.nicknameMatchesEmpty))
            return
        }
        
        guard let _ = applicationID, let apiToken else {
            completionHandler?(.failure(UserManagerError.notInitialized))
            return
        }
        
        guard let url = URL(string: remoteConfiguration.url(pathType: .getUsers)) else {
            completionHandler?(.failure(UserManagerError.badURL))
            return
        }
        
        let storedUsers = userStorage.getUsers(for: nicknameMatches)
        let request = UserRequest<SBUsers>(url: url, method: "GET", header: ["Api-Token": apiToken], parameters: ["nickname": nicknameMatches, "limit": 100])
        
        networkClient.request(request: request) { [weak self] result in
            guard let self else {
                completionHandler?(.failure(UserManagerError.unexpectedRelease))
                return
            }
            switch result {
            case .success(let users) :
                users.users.forEach {
                    self.userStorage.upsertUser($0)
                }
                completionHandler?(.success(users.users))
            case .failure(let error):
                if storedUsers.count > 0 {
                    completionHandler?(.success(storedUsers))
                } else {
                    completionHandler?(.failure(error))
                }
            }
        }
    }
}
