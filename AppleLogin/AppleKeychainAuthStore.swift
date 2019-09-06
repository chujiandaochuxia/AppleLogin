//
//  AppleKeychainAuthStore.swift
//  AppleLogin
//
//  Created by imac on 2019/9/6.
//  Copyright © 2019 代亚洲. All rights reserved.
//

import Foundation

struct AppInfo {
    static let BundleIdentifier = Bundle.main.bundleIdentifier!
}
enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unexpectedItemData
    case unhandledError
}
struct CRAppleKeychainAuthStore {
    
    let service: String
    let accessGroup: String?
    private(set) var account: String
    
    // MARK: Intialization
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    func readItem() throws -> String {
        /*
         构建一个查询来查找与服务、帐户和匹配的项访问组。
         */
        var query = CRAppleKeychainAuthStore.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // 尝试获取与查询匹配的现有密钥链项。
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // 检查返回状态，并在适当时抛出错误。
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }
        
        // 从查询结果解析密码字符串。
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    func saveItem(_ password: String) throws {
        // 将密码编码到数据对象中。
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // 检查密钥链中的现有项。
            try _ = readItem()
            
            // 使用新密码更新现有项。
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = CRAppleKeychainAuthStore.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // 如果返回意外状态，则抛出错误。
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            /*
             密钥链中没有找到密码。创建一个要保存的字典 作为一个新的键链项。
             */
            var newItem = CRAppleKeychainAuthStore.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // 将新项添加到密钥链。
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // 如果返回意外状态，则抛出错误。
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }
    
    func deleteItem() throws {
        // 从密钥链中删除现有项。
        let query = CRAppleKeychainAuthStore.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // 如果返回意外状态，则抛出错误。
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
    // MARK: Convenience
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    static var currentUserIdentifier: String {
        do {
            let storedIdentifier = try CRAppleKeychainAuthStore(service: AppInfo.BundleIdentifier, account: "user_Identifier").readItem()
            return storedIdentifier
        } catch {
            print("currentUserIdentifier 为空")
            return ""
        }
    }
    
    static func deleteUserIdentifierFromKeychain() {
        do {
            try CRAppleKeychainAuthStore(service: AppInfo.BundleIdentifier, account: "user_Identifier").deleteItem()
        } catch {
            print("删除失败")
        }
    }
}
