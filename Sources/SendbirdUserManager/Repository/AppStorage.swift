//
//  AppStorageProtoocol.swift
//
//
//  Created by 윤다원 on 11/4/24.
//

import Foundation

public protocol AppStorageProtoocol {
    func loadAppID() -> String?
    func storeAppID(_ appID: String)
    func removeAll()
}

public class AppStorage: AppStorageProtoocol {
    let appIDKey = "app_Id"
    let userDefaults = UserDefaults.standard
    
    public init() {}
    
    public func loadAppID() -> String? {
        userDefaults.string(forKey: appIDKey)
    }
    
    public func storeAppID(_ appID: String) {
        userDefaults.setValue(appID, forKey: appIDKey)
    }
    
    public func removeAll() {
        userDefaults.removeObject(forKey: appIDKey)
    }
}
