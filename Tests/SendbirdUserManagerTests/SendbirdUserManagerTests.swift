//
//  SendbirdUserManagerTests.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import XCTest
@testable import SendbirdUserManager

final class UserManagerTests: UserManagerBaseTests {
    override func userManager() -> SBUserManager {
        UserManager(networkClient: MockNetworkClient(), userStorage: UserStorage())
    }
}

final class UserStorageTests: UserStorageBaseTests {
    let storage = UserStorage()
    override func tearDownWithError() throws {
        storage.removeAllUsers()
    }
    override func userStorage() -> SBUserStorage? {
        storage
    }
}

//final class NetworkClientTests: NetworkClientBaseTests {
//    override func networkClient() -> SBNetworkClient? {
//        NetworkClient()
//    }
//}
