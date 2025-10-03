//
//  MoreAppsIcon.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

import SwiftUI

private class MoreAppsIconModel: ObservableObject {
    @Published var resizable: Bool = false
}

// MARK: - MoreAppsIcon
public struct MoreAppsIcon: View, @MainActor Equatable {
    public static func == (lhs: MoreAppsIcon, rhs: MoreAppsIcon) -> Bool {
        return lhs.appId == rhs.appId
            && lhs.appstoreId == rhs.appstoreId
            && lhs.size == rhs.size
    }
    @ObservedObject private var viewModel: MoreAppsIconModel = .init()
    var appId: String
    var appstoreId: String
    var size: Int = 30
    @State private var nsuiImage: NSUIImage = .init()
    @State private var isLoading: Bool = false
    @State private var loadTask: Task<Void, Never>?
    @State private var hasAttemptedLoad: Bool = false
    
    public init(appId: String, appstoreId: String, size: Int = 30) {
        self.appId = appId
        self.appstoreId = appstoreId
        self.size = size
    }
    private var cacheKey: String {
        return "\(appId)_\(appstoreId)_\(size)~125"
    }
    public var body: some View {
        Group {
            if viewModel.resizable == true {
                Image(nsuiImage: nsuiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(placeholderView)
            } else {
                Image(nsuiImage: nsuiImage)
                    .background(placeholderView)
            }
        }
        .frame(width: CGFloat(size), height: CGFloat(size))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onAppear {
            if !hasAttemptedLoad {
                loadIconIfNeeded()
            }
        }
        .onDisappear {
            cancelLoading()
        }
        .id(cacheKey) // Ensure reload when cache key changes
    }
    
    private func cancelLoading() {
        loadTask?.cancel()
        loadTask = nil
        if isLoading {
            isLoading = false
        }
    }
    
    public func resizable() -> some View {
        let view = self
        view.viewModel.resizable = true
        return view
    }
    
    // Separate computed property to reduce body complexity
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.accentColor.opacity(isLoading ? 0.3 : 0))
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.8)
                    }
                }
            )
    }
    /// Process cached icon data and resize to target size
    /// This allows us to cache original icon data globally and generate different sizes on demand
    private func processImageData(_ data: Data) async -> NSUIImage? {
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .utility) { // Lower priority for better UI responsiveness
                let result: NSUIImage? = autoreleasepool {
                    guard let image = NSUIImage(data: data) else { return nil }
                    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
                    let targetSize = NSSize(width: size, height: size)
                    #else
                    let targetSize = CGSize(width: size, height: size)
                    #endif
                    // Batch image operations to reduce context switches
                    let resized = image.resized(to: targetSize)
                    
                    // Yield to allow other tasks if needed
                    if Task.isCancelled { return nil }
                    
                    return resized
                }
                continuation.resume(returning: result)
            }
        }
    }
    private func loadIconIfNeeded() {
        guard !isLoading && !hasAttemptedLoad else { return }
        
        // Mark as attempted to prevent re-triggering
        hasAttemptedLoad = true
        
        // Asynchronously check cache and load
        loadTask = Task { @MainActor in
            // 1️⃣ Check cache first (non-blocking)
            if let cachedData: Data = await AppIconCache.shared.getIcon(for: cacheKey) {
                // Process image on background thread
                let resizedImage = await processImageData(cachedData)
                
                guard !Task.isCancelled else { return }
                
                // Single UI update
                self.nsuiImage = resizedImage ?? .init()
                return
            }
            // 2️⃣ No cache available, show loading state briefly
            self.isLoading = true
            
            let appIcon: Data? = await MyAppList.getAppIcon(forId: appId, appstoreId: appstoreId)
            
            guard !Task.isCancelled else {
                self.isLoading = false
                self.loadTask = nil
                return
            }
            
            guard let iconData = appIcon else {
                self.isLoading = false
                self.loadTask = nil
                return
            }
            
            // Save to cache (background)
            Task.detached {
                await AppIconCache.shared.setIcon(iconData, for: cacheKey)
            }
            
            // Process image (background)
            let processedImage = await processImageData(iconData)
            
            guard !Task.isCancelled else {
                self.loadTask = nil
                return
            }
            
            // Single UI update with both state changes
            self.nsuiImage = processedImage ?? .init()
            self.isLoading = false
            self.loadTask = nil
        }
    }
}
