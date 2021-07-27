//
//  KeychainWrapper.swift
//  XWallet
//
//  Created by loj on 08.02.18.
//

import Foundation


public class KeychainWrapper {
    
    public static let `default` = KeychainWrapper()
    
    private init() {}
    
    // This is recommended for items that need to be accessible only while the application is in the foreground.
    // Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different
    // device, these items will not be present.
    private let accessibility = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

    // Item data can only be accessed once the device has been unlocked after a restart.
    // This is recommended for items that need to be accessible by background
    // applications. Items with this attribute will never migrate to a new
    // device, so after a backup is restored to a new device these items will
    // be missing.
//    private let accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    private let serviceName = "iVault"

    public func getValue(forKey key: String) -> String? {
        guard let keychainData = getData(forKey: key) else {
            return nil
        }
        return String(data: keychainData, encoding: String.Encoding.utf8) as String?
    }
    
    public func set(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            return
        }
        set(value: data, forKey: key)
    }
    
    public func removeValue(forKey key: String) {
        let keychainQueryDictionary = buildQuery(forKey: key)
        SecItemDelete(keychainQueryDictionary as CFDictionary)
    }
    
    
    private func update(_ value: Data, forKey key: String) {
        let keychainQueryDictionary: [CFString:Any] = buildQuery(forKey: key)
        let updateDictionary = [kSecValueData:value]

        SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
    }
    
    private func getData(forKey key: String) -> Data? {
        var keychainQueryDictionary = buildQuery(forKey: key)
        keychainQueryDictionary[kSecMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[kSecReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    private func set(value: Data, forKey key: String) {
        var keychainQueryDictionary: [CFString:Any] = buildQuery(forKey: key)
        keychainQueryDictionary[kSecValueData] = value
        keychainQueryDictionary[kSecAttrAccessible] = self.accessibility
        
        let status = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        if status == errSecDuplicateItem {
            update(value, forKey: key)
        }
    }

    private func buildQuery(forKey key: String) -> [CFString:Any] {
        var keychainQueryDictionary: [CFString:Any] = [kSecClass:kSecClassGenericPassword]
        keychainQueryDictionary[kSecAttrService] = self.serviceName
        keychainQueryDictionary[kSecAttrAccessible] = self.accessibility
        
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        keychainQueryDictionary[kSecAttrGeneric] = encodedIdentifier
        keychainQueryDictionary[kSecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}




