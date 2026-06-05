# [WWCacheManager](https://swiftpackageindex.com/William-Weng)

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![](https://img.shields.io/github/v/tag/William-Weng/WWCacheManager)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

[English](./README.en.md) | [正體中文](./README.md)

一個高效、線程安全的快取管理器，支援 `DispatchQueue` 讀寫鎖和 `@propertyWrapper` 語法。

![Example](https://github.com/user-attachments/assets/8c0b3475-49bc-4158-bdf3-c1a705c2b445)

## ✨ 特性

- 🚀 **線程安全**：使用 `DispatchQueue` 讀寫鎖（ concurrent + barrier）
- ⚡ **讀取並行**：多個讀取操作可同時執行
- 🔒 **寫入互斥**：寫入操作阻塞其他所有操作
- 📦 **Property Wrapper**：支援 `@WWCacheValue`，像普通屬性一樣使用
- 🎯 **類型安全**：泛型支援 `KeyType: Hashable`, `ObjectType: AnyObject`
- 💰 **權重追蹤**：支援 `cost` 參數，可用於 LRU eviction（需手動實作）
- 📏 **限制支援**：`countLimit` 和 `totalCostLimit`（需手動檢查）

## 📦 安裝

### Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/WWCacheManager.git", from: "1.1.0")
]
```

### 手動安裝

將 `WWCacheManager.swift` 和 `WWCacheValue.swift` 複製到你的專案中。

## 📖 使用範例

### 基本用法（直接呼叫）

```swift
import UIKit
import WWCacheManager

final class ViewController: UIViewController {
    
    private let manager = WWCacheManager<String, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        demo()
    }
    
    func demo() {
        let key = "heartImage"
        
        // ✅ 設定值
        manager.setValue(UIImage(systemName: "heart.fill"), forKey: key)
        
        // ✅ 讀取值
        if let image = manager.value(forKey: key) {
            print("Cache Image => \(image.size)")
        }
        
        // ✅ 檢查存在
        if manager.contains(forKey: key) {
            print("Image exists in cache")
        }
        
        // ✅ 獲取數量
        let count = manager.count()
        print("Cache count => \(count)")
        
        // ✅ 獲取所有鍵
        let keys = manager.allKeys()
        print("All keys => \(keys)")
        
        // ✅ 移除值
        manager.removeValue(forKey: key)
        print("Cache Remove => \(String(describing: manager.value(forKey: key)))")
        
        // ✅ 清空所有
        manager.removeAll()
    }
}
```

### Property Wrapper 語法（推薦 ⭐⭐⭐⭐）

```swift
import UIKit
import WWCacheManager

final class ViewController: UIViewController {
    
    private let manager = WWCacheManager<String, UIImage>()
    
    // ✅ 使用 Property Wrapper（同步語法，不需要 await）
    @WWCacheValue(manager, "heartImage") var heartImage
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cacheString("Hello, World!", for: "word")
        cacheImage(UIImage(systemName: "heart.fill"))
    }
}

private extension ViewController {
    
    func cacheString(_ string: String, for key: String) {
        
        let manager = WWCacheManager<String, Data>()
        let data = string.data(using: .utf8)!
        
        // ✅ 設定值
        manager.setValue(data, forKey: key)
        
        // ✅ 讀取值
        let cacheData = manager.value(forKey: key)!
        let cacheString = String(data: cacheData, encoding: .utf8)!
        print("Cache String => \(cacheString)")
        
        // ✅ 移除值
        manager.removeValue(forKey: key)
        print("Cache Remove => \(String(describing: manager.value(forKey: key)))")
    }
    
    func cacheImage(_ image: UIImage?) {
        
        // ✅ 設定值（像普通屬性一樣）
        heartImage = image
        print("Cache Image => \(heartImage!.size)")
        
        // ✅ 設定 nil（自動移除快取）
        heartImage = nil
        print("Cache Remove => \(String(describing: heartImage))")
    }
}
```

### 初始化支援初始值

```swift
// ✅ 方式 1：不指定初始值（nil）
@WWCacheValue(manager, "heartImage") var heartImage

// ✅ 方式 2：指定初始值
@WWCacheValue(wrappedValue: UIImage(systemName: "star"), manager, "defaultStar") var defaultStar
```

### 多線程測試

```swift
let manager = WWCacheManager<String, String>()

// ✅ 寫入（barrier，互斥）
Task {
    for i in 0..<100 {
        manager.setValue("value\(i)", forKey: "key\(i)")
    }
}

// ✅ 讀取（sync，可並行）
for i in 0..<10 {
    Task {
        for j in 0..<100 {
            let value = manager.value(forKey: "key\(j)")
            print("Thread \(i): \(value)")
        }
    }
}

// ✅ 不會 crash，數據一致！
```

## 📊 API 參考

### WWCacheManager

| 方法 | 說明 |
|------|------|
| `init(countLimit:totalCostLimit:)` | 初始化快取管理器 |
| `setValue(_:forKey:cost:)` | 設定值（支援權重） |
| `value(forKey:)` | 讀取值 |
| `contains(forKey:)` | 檢查是否包含鍵 |
| `count()` | 獲取快取數量 |
| `allKeys()` | 獲取所有鍵 |
| `removeValue(forKey:)` | 移除單個值 |
| `removeAll()` | 清空所有 |
| `setCountLimit(_:)` | 設定最大數量 |
| `setTotalCostLimit(_:)` | 設定最大容量 |

### WWCacheValue（Property Wrapper）

| 屬性/方法 | 說明 |
|----------|------|
| `wrappedValue` | 快取值（讀取/設定） |
| `init(_:_:)` | 初始化（初始值 nil） |
| `init(wrappedValue:_:_:)` | 初始化（指定初始值） |

## ⚠️ 注意事項

1. **KeyType 必須是 `Hashable`**：例如 `String`, `Int`, `UUID`
2. **ObjectType 必須是 `AnyObject`**：例如 `UIImage`, `NSData`, 自定義類別
3. **Property Wrapper 只能用於 `class`**：`struct` 可能有不當的 `mutating` 問題
4. **`countLimit` 和 `totalCostLimit` 不會自動 evict**：需手動檢查並移除
5. **讀取是同步的**：不適合長時間阻塞的操作

## 🆚 比較

| 特性 | WWCacheManager (讀寫鎖) | actor | NSCache |
|------|------------------------|-------|---------|
| 線程安全 | ✅ 讀寫鎖 | ✅ actor | ✅ 內建 |
| 讀取性能 | ⭐⭐⭐⭐⭐ 可並行 | ⭐⭐⭐ 需要 await | ⭐⭐⭐⭐ 內建 |
| 寫入性能 | ⭐⭐⭐⭐ barrier | ⭐⭐⭐ 需要 await | ⭐⭐⭐⭐ 內建 |
| Property Wrapper | ✅ 支援 | ❌ 不支援 | ❌ 不支援 |
| 需要 `await` | ❌ 不需要 | ✅ 需要 | ❌ 不需要 |
| 自動 evict | ❌ 需手動 | ❌ 需手動 | ✅ 內建 |
| 遍歷/計數 | ✅ 支援 | ❌ 不支援 | ❌ 不支援 |

