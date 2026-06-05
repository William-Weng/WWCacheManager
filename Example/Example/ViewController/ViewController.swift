//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/10/17.
//

import UIKit
import WWCacheManager

final class ViewController: UIViewController {
    
    static let manager = WWCacheManager<String, UIImage>()
    
    @WWCacheValue(ViewController.manager, "heartImage") var heartImage
    
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
        
        manager.setValue(data, forKey: key)
        
        let cacheData = manager.value(forKey: key)!
        let cacheString = String(data: cacheData, encoding: .utf8)!
        print("Cache String => \(cacheString)")
        
        manager.removeValue(forKey: key)
        print("Cache Remove => \(String(describing: manager.value(forKey: key)))")
    }
    
    func cacheImage(_ image: UIImage?) {
        
        heartImage = image
        print("Cache Image => \(heartImage!.size)")
        
        heartImage = nil
        print("Cache Remove => \(String(describing: heartImage))")
    }
}
