//
//  IconCache.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

import Foundation

// MARK: - Icon cache management
public actor AppIconCache {
    public static let shared = AppIconCache()
    private let cache = NSCache<NSString, NSData>()
    private let loadingKeys = Set<String>()
    
    public init() {
        cache.countLimit = 100 // Maximum 100 icons cache
        cache.totalCostLimit = 30 * 1024 * 1024 // Reduced to 30MB for better memory management
        
        // Configure memory cache
        cache.name = "AppIconCache"
        
        // Setup memory warning observer - using traditional approach to avoid warnings
        #if canImport(UIKit)
        setupMemoryWarningObserver()
        #endif
    }
    
    public func getIcon(for key: String) -> Data? {
        if let cachedData = cache.object(forKey: key as NSString) as Data? {
            return cachedData
        }
        return nil
    }
    
    public func setIcon(_ data: Data, for key: String) {
        // Use lower cost calculation for better performance
        let cost = min(data.count, 1024 * 1024) // Cap cost at 1MB per item
        cache.setObject(data as NSData, forKey: key as NSString, cost: cost)
    }
    
    public func isLoading(key: String) -> Bool {
        return loadingKeys.contains(key)
    }
    
    func markAsLoading(_ key: String) {
        var mutableSet = loadingKeys
        mutableSet.insert(key)
    }
    
    func markAsLoaded(_ key: String) {
        var mutableSet = loadingKeys
        mutableSet.remove(key)
    }
    
    public func clearCache() {
        cache.removeAllObjects()
    }
    
    @MainActor
    public func clearMemoryCache() {
        DispatchQueue.main.async {
            self.cache.removeAllObjects()
        }
    }
    
    #if canImport(UIKit)
    private nonisolated func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.clearMemoryCache()
            }
        }
    }
    #endif
}
