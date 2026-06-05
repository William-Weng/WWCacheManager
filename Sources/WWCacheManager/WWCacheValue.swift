//
//  WWCacheValue.swift
//  WWCacheManager
//
//  Created by William.Weng on 2026/6/5.
//
/// 快取屬性包裝器（Property Wrapper）
/// - 使用同步語法，不需要 `await`（因為 WWCacheManager 使用 DispatchQueue 讀寫鎖）
/// - 支援直接像普通屬性一樣讀取/設定
/// - 自動處理 nil 值（設定 nil 會移除快取）

import Foundation

// MARK: - WWCacheValue
@propertyWrapper
public struct WWCacheValue<KeyType, ObjectType> where KeyType: Hashable, ObjectType: AnyObject {
    
    let key: KeyType                                    // 快取鍵值
    let manager: WWCacheManager<KeyType, ObjectType>    // 快取管理器
    
    public var wrappedValue: ObjectType? {
        
        get {
            return manager.value(forKey: key)
        }
        set {
            if let newValue { manager.setValue(newValue, forKey: key); return }
            manager.removeValue(forKey: key)
        }
    }
    
    /// 初始化屬性包裝器
    /// - Parameters:
    ///   - manager: 快取管理器
    ///   - key: 快取鍵值
    public init(_ manager: WWCacheManager<KeyType, ObjectType>, _ key: KeyType) {
        self.manager = manager
        self.key = key
    }
}

