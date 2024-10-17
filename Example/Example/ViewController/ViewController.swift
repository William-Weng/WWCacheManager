//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/10/17.
//

import UIKit
import WWPrint
import WWCacheManager

// MARK: - ViewController
final class ViewController: UIViewController {

    static let manager = WWCacheManager<NSString, UIImage>.build()
    
    @WWCacheValue(ViewController.manager, "heartImage") var heartImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cacheManagerDemo()
        cacheValueDemo()
    }
}

// MARK: - Demo
private extension ViewController {
    
    func cacheManagerDemo() {
        
        let manager = WWCacheManager<NSString, NSData>.build()
        let key = "cache" as NSString
        let data = "Hello, WWCacheManager!".data(using: .utf8)! as NSData
        
        manager.setValue(data, forKey: key)
        wwPrint(manager.value(forKey: key))
        
        manager.removeValue(forKey: key)
        wwPrint(manager.value(forKey: key))
    }
    
    func cacheValueDemo() {
                
        heartImage = UIImage(systemName: "heart.fill")
        wwPrint(heartImage)
        
        heartImage = nil
        wwPrint(heartImage)
    }
}
