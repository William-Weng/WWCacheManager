# WWCacheManager

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![](https://img.shields.io/github/v/tag/William-Weng/WWCacheManager)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

[English](./README.en.md) | [正體中文](./README.md)

An efficient, thread-safe cache manager that supports `DispatchQueue` read-write locking and `@propertyWrapper` syntax.

## ✨ Features

- 🚀 **Thread-safe**: Uses `DispatchQueue` read-write locking (`concurrent` + `barrier`).
- ⚡ **Concurrent reads**: Multiple read operations can run at the same time.
- 🔒 **Exclusive writes**: Write operations block all other access.
- 📦 **Property Wrapper**: Supports `@WWCacheValue`, so values can be accessed like normal properties.
- 🎯 **Type-safe**: Generic constraints support `KeyType: Hashable` and `ObjectType: AnyObject`.
- 💰 **Cost tracking**: Supports the `cost` parameter, which can be used for LRU eviction logic if you implement it yourself.
- 📏 **Limit support**: `countLimit` and `totalCostLimit` are supported, but eviction must be handled manually.

## 📦 Installation

### Swift Package Manager

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/WWCacheManager.git", from: "1.1.0")
]
```

### Manual Installation

Copy `WWCacheManager.swift` and `WWCacheValue.swift` into your project.

## 📖 Usage Examples

### Basic Usage

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
        
        // ✅ Set value
        manager.setValue(UIImage(systemName: "heart.fill"), forKey: key)
        
        // ✅ Read value
        if let image = manager.value(forKey: key) {
            print("Cache Image => \(image.size)")
        }
        
        // ✅ Check existence
        if manager.contains(forKey: key) {
            print("Image exists in cache")
        }
        
        // ✅ Get count
        let count = manager.count()
        print("Cache count => \(count)")
        
        // ✅ Get all keys
        let keys = manager.allKeys()
        print("All keys => \(keys)")
        
        // ✅ Remove value
        manager.removeValue(forKey: key)
        print("Cache Remove => \(String(describing: manager.value(forKey: key)))")
        
        // ✅ Remove all
        manager.removeAll()
    }
}
```

### Property Wrapper Syntax

```swift
import UIKit
import WWCacheManager

final class ViewController: UIViewController {
    
    private let manager = WWCacheManager<String, UIImage>()
    
    // ✅ Property Wrapper usage (synchronous syntax, no await needed)
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
        
        // ✅ Set value
        manager.setValue(data, forKey: key)
        
        // ✅ Read value
        let cacheData = manager.value(forKey: key)!
        let cacheString = String(data: cacheData, encoding: .utf8)!
        print("Cache String => \(cacheString)")
        
        // ✅ Remove value
        manager.removeValue(forKey: key)
        print("Cache Remove => \(String(describing: manager.value(forKey: key)))")
    }
    
    func cacheImage(_ image: UIImage?) {
        
        // ✅ Set value like a normal property
        heartImage = image
        print("Cache Image => \(heartImage!.size)")
        
        // ✅ Set nil to remove the cached value automatically
        heartImage = nil
        print("Cache Remove => \(String(describing: heartImage))")
    }
}
```

### Initial Value Support

```swift
// ✅ Option 1: No initial value (nil)
@WWCacheValue(manager, "heartImage") var heartImage

// ✅ Option 2: With initial value
@WWCacheValue(wrappedValue: UIImage(systemName: "star"), manager, "defaultStar") var defaultStar
```

### Multithreaded Test

```swift
let manager = WWCacheManager<String, String>()

// ✅ Writes (barrier, exclusive)
Task {
    for i in 0..<100 {
        manager.setValue("value\(i)", forKey: "key\(i)")
    }
}

// ✅ Reads (sync, concurrent)
for i in 0..<10 {
    Task {
        for j in 0..<100 {
            let value = manager.value(forKey: "key\(j)")
            print("Thread \(i): \(value)")
        }
    }
}

// ✅ No crash, consistent results
```

## 📊 API Reference

### WWCacheManager

| Method | Description |
|------|------|
| `init(countLimit:totalCostLimit:)` | Initializes the cache manager. |
| `setValue(_:forKey:cost:)` | Sets a value, with optional cost. |
| `value(forKey:)` | Reads a value. |
| `contains(forKey:)` | Checks whether a key exists. |
| `count()` | Returns the number of cached items. |
| `allKeys()` | Returns all keys. |
| `removeValue(forKey:)` | Removes a single value. |
| `removeAll()` | Removes all values. |
| `setCountLimit(_:)` | Sets the maximum item count. |
| `setTotalCostLimit(_:)` | Sets the maximum total cost. |

### WWCacheValue (Property Wrapper)

| Property/Method | Description |
|----------|------|
| `wrappedValue` | Cached value (read/write). |
| `init(_:_:)` | Initializes with no initial value. |
| `init(wrappedValue:_:_:)` | Initializes with an initial value. |

## ⚠️ Notes

1. **`KeyType` must be `Hashable`**: for example `String`, `Int`, or `UUID`.
2. **`ObjectType` must be `AnyObject`**: for example `UIImage`, `NSData`, or your own class types.
3. **Property Wrapper is for classes only**: using it inside a `struct` may cause `mutating`-related issues.
4. **`countLimit` and `totalCostLimit` do not evict automatically**: you need to remove items yourself.
5. **Reads are synchronous**: it is not ideal for long-running blocking work.

## 🆚 Comparison

| Feature | WWCacheManager (Read-Write Lock) | actor | NSCache |
|------|------------------------|-------|---------|
| Thread safety | ✅ Read-write lock | ✅ actor | ✅ Built-in |
| Read performance | ⭐⭐⭐⭐⭐ Concurrent | ⭐⭐⭐ Requires await | ⭐⭐⭐⭐ Built-in |
| Write performance | ⭐⭐⭐⭐ barrier | ⭐⭐⭐ Requires await | ⭐⭐⭐⭐ Built-in |
| Property Wrapper | ✅ Supported | ❌ Not supported | ❌ Not supported |
| Requires `await` | ❌ No | ✅ Yes | ❌ No |
| Automatic eviction | ❌ Manual | ❌ Manual | ✅ Built-in |
| Enumeration / count | ✅ Supported | ❌ Not supported | ❌ Not supported |
