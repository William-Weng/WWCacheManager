//
//  WWCacheValue.swift
//  WWCacheManager
//
//  Created by William.Weng on 2024/10/17.
//

import Foundation

// MARK: - WWCacheValue
@propertyWrapper
public struct WWCacheValue<KeyType, ObjectType> where KeyType: AnyObject, ObjectType: AnyObject {
    
    let key: KeyType
    let manager: WWCacheManager<KeyType, ObjectType>
    
    public var wrappedValue: ObjectType? {
        
        get {
            return manager.value(forKey: key)
        }
        set {
            if let newValue { manager.setValue(newValue, forKey: key); return }
            manager.removeValue(forKey: key)
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - manager: WWCacheManager
    ///   - key: KeyType
    public init(_ manager: WWCacheManager<KeyType, ObjectType>, _ key: KeyType) {
        self.manager = manager
        self.key = key
    }
}
