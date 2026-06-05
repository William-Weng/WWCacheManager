//
//  WWCacheManager.swift
//  WWCacheManager
//
//  Created by William.Weng on 2026/6/5.
//
/// 使用 DispatchQueue (讀寫鎖) 實現線程安全的快取管理器
/// - 讀取：使用 concurrent queue（多個讀取可並行）
/// - 寫入：使用 barrier（寫入時互斥，阻塞其他所有操作）
/// - 支援 key 的權重值 (cost) 追蹤
/// - 支援 countLimit 和 totalCostLimit 限制（需手動實作 evict 邏輯）

import Foundation

// MARK: - WWCacheManager
public class WWCacheManager<KeyType, ObjectType> where KeyType: Hashable {
    
    /// 併發 queue（讀寫鎖實現）
    /// - sync: 讀取可並行（多 reader）
    /// - barrier: 寫入互斥（單 writer）
    private let queue = DispatchQueue(label: "com.wwcache.async", attributes: .concurrent)
    
    private var cache: [KeyType: ObjectType] = [:]      // 快取資料：Key -> Value
    private var costs: [KeyType: Int] = [:]             // 權重值追蹤：Key -> Cost（用於 totalCostLimit 計算）
    
    private var _countLimit: Int
    private var _totalCostLimit: Int
    
    /// 初始化快取管理器
    /// - Parameters:
    ///   - countLimit: 最多快取的數量（預設 100 個）
    ///   - totalCostLimit: 最多快取的容量（預設 100MB = 100 * 1024 * 1024）
    public init(countLimit: Int = 100, totalCostLimit: Int = 100 * 1024 * 1024) {
        _countLimit = countLimit
        _totalCostLimit = totalCostLimit
    }
}

/// 讀取：使用 sync（併發執行）
public extension WWCacheManager {
    
    /// 讀取數值
    /// - Parameter key: 鍵值
    /// - Returns: 快取中的物件或 nil
    func value(forKey key: KeyType) -> ObjectType? {
        queue.sync { cache[key] }
    }
    
    /// 檢查是否包含指定鍵
    /// - Parameter key: 鍵值
    /// - Returns: true 如果快取中包含該鍵
    func contains(forKey key: KeyType) -> Bool {
        return queue.sync { cache[key] != nil }
    }
    
    /// 獲取快取中的物件數量（async）
    /// - Returns: 當前快取的物件數量
    func count() async -> Int {
        return queue.sync { cache.count }
    }
    
    /// 獲取所有鍵（async）
    /// - Returns: 所有鍵的陣列
    func allKeys() async -> [KeyType] {
        return queue.sync { Array(cache.keys) }
    }
}

/// 寫入：使用 barrier（互斥執行）
public extension WWCacheManager {
        
    /// 設定數值
    /// - Parameters:
    ///   - value: 要快取的物件
    ///   - key: 鍵值
    ///   - cost: 權重值（預設 0），用於 totalCostLimit 計算
    func setValue(_ value: ObjectType, forKey key: KeyType, cost: Int = 0) {
        
        queue.async(flags: .barrier) { [self] in
            cache[key] = value
            costs[key] = cost
        }
    }
    
    /// 移除數值
    /// - Parameter key: 鍵值
    func removeValue(forKey key: KeyType) {
        
        queue.async(flags: .barrier) { [self] in
            cache.removeValue(forKey: key)
            costs.removeValue(forKey: key)
        }
    }
    
    /// 移除全部數值
    func removeAll() {
        
        queue.async(flags: .barrier) { [self] in
            cache.removeAll()
            costs.removeAll()
        }
    }
    
    /// 設定 countLimit（最大快取數量）
    /// - Parameter limit: 新的數量限制
    func setCountLimit(_ limit: Int) {
        
        queue.async(flags: .barrier) { [self] in
            _countLimit = limit
        }
    }
    
    /// 設定 totalCostLimit（最大快取容量）
    /// - Parameter limit: 新的容量限制
    func setTotalCostLimit(_ limit: Int) {
        
        queue.async(flags: .barrier) { [self] in
            _totalCostLimit = limit
        }
    }
}

