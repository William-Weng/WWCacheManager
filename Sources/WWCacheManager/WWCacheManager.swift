//
//  WWCacheManager.swift
//  WWCacheManager
//
//  Created by William.Weng on 2024/10/17.
//

import Foundation

// MARK: - WWCacheManager
open class WWCacheManager<KeyType, ObjectType>: NSObject where KeyType: AnyObject, ObjectType: AnyObject {
    
    private var cache: NSCache<KeyType, ObjectType> = NSCache()
    
    private override init() { super.init() }
    
    /// 初始化
    /// - Parameter cache: NSCache<KeyType, ObjectType>
    private convenience init(cache: NSCache<KeyType, ObjectType>) {
        self.init()
        self.cache = cache
    }
}

// MARK: - public static function
public extension WWCacheManager {
    
    /// [建立WWCache](https://juejin.cn/post/6844903810528182280)
    /// - Parameters:
    ///   - countLimit: 最多快取的數量 => 100個
    ///   - totalCostLimit: 最多快取的容量 => 10MB
    /// - Returns: WWCacheManager
    static func build(countLimit: Int = 100, totalCostLimit: Int = 10 * 1024 * 1024, delegate: NSCacheDelegate? = nil) -> WWCacheManager {
        
        let cache = NSCache<KeyType, ObjectType>()
        
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
        cache.delegate = delegate
        
        return WWCacheManager(cache: cache)
    }
}

// MARK: - public function
public extension WWCacheManager {
    
    /// [設定數值](https://medium.com/@master13sust/to-nscache-or-not-to-nscache-what-is-the-urlcache-35a0c3b02598)
    /// - Parameters:
    ///   - value: <ObjectType>
    ///   - key: <KeyType>
    ///   - cost: 權重值 => 0
    func setValue(_ value: ObjectType, forKey key: KeyType, cost: Int = 0) {
        cache.setObject(value, forKey: key, cost: cost)
    }
    
    /// 讀取數值
    /// - Parameter key: <KeyType>
    /// - Returns: <ObjectType?>
    func value(forKey key: KeyType) -> ObjectType? {
        return cache.object(forKey: key)
    }
    
    /// 移除數值
    /// - Parameter key: <KeyType>
    func removeValue(forKey key: KeyType) {
        cache.removeObject(forKey: key)
    }
    
    /// 移除全部的數值
    func removeAll() {
        cache.removeAllObjects()
    }
}
