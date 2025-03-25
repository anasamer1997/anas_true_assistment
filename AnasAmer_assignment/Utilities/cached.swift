//
//  cached.swift
//  AnasAmer_assignment
//
//  Created by anas amer on 25/03/2025.
//

import Foundation
// Services/CacheManager.swift
class CacheManager {
    static let shared = CacheManager()
    private let memoryCache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ProductsCache")
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory,
                                      withIntermediateDirectories: true)
    }
    
    func save(products: [Product], forKey key: String) {
        let nsKey = key as NSString
        
        do {
            let data = try JSONEncoder().encode(products)
            // Save to memory
            memoryCache.setObject(data as NSData, forKey: nsKey)
            // Save to disk
            let fileURL = cacheDirectory.appendingPathComponent(key)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save products to cache: \(error)")
        }
    }
    
    func loadProducts(forKey key: String) -> [Product]? {
        let nsKey = key as NSString
        
        // Check memory cache first
        if let memoryData = memoryCache.object(forKey: nsKey) as Data?,
           let products = try? JSONDecoder().decode([Product].self, from: memoryData) {
            return products
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard let diskData = try? Data(contentsOf: fileURL),
              let products = try? JSONDecoder().decode([Product].self, from: diskData) else {
            return nil
        }
        
        // Store in memory cache for future access
        memoryCache.setObject(diskData as NSData, forKey: nsKey)
        return products
    }
    
    func loadAnyProducts() -> [Product]? {
        // Check common limit values (7, 14, 21, etc.)
        for limit in stride(from: 7, through: 35, by: 7) {
            let key = "products_\(limit)"
            if let products = loadProducts(forKey: key) {
                return products
            }
        }
        return nil
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
    }
}
