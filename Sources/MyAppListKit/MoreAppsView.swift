//
//  MoreToolsView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension NSImage {
    public func resized(to newSize: NSSize) -> NSImage {
        // 优先选择最佳的 NSImageRep（矢量图/位图时更清晰）
        if let rep = self.bestRepresentation(for: CGRect(origin: .zero, size: newSize),
                                             context: nil,
                                             hints: nil) {
            let image = NSImage(size: newSize)
            image.lockFocus()
            NSGraphicsContext.current?.imageInterpolation = .high
            defer { image.unlockFocus() }
            rep.draw(in: CGRect(origin: .zero, size: newSize))
            return image
        }
        // fallback: 常规缩放绘制
        let image = NSImage(size: newSize)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: CGRect(origin: .zero, size: newSize),
                  from: CGRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        image.unlockFocus()
        return image
    }
    public func toPNGData() -> Data? {
        let rect = NSRect(origin: .zero, size: self.size)
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(rect.width),
            pixelsHigh: Int(rect.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { return nil }
        
        NSGraphicsContext.saveGraphicsState()
        if let context = NSGraphicsContext(bitmapImageRep: rep) {
            NSGraphicsContext.current = context
            self.draw(in: rect)
            context.flushGraphics()
        }
        NSGraphicsContext.restoreGraphicsState()
        
        return rep.representation(using: .png, properties: [:])
    }
}
#elseif canImport(UIKit)
extension UIImage {
    public func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    func toData() -> Data? {
        return self.pngData()
    }
}
#endif

extension MyAppList {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Get local app icon
    public static func getAppIcon(forId: String = "com.apple.AppStore", defaultAppStore: Bool = false) -> NSImage? {
        guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: forId) else {
            if defaultAppStore == true {
                return getAppIcon()
            }
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appUrl.path())
    }
    @MainActor
    public static func getAppIcon(forId bundleIdentifier: String = "com.apple.AppStore", appstoreId: String? = nil) async -> NSImage? {
        guard let imageData: Data = await getAppIcon(forId: bundleIdentifier, appstoreId: appstoreId) else { return nil }
        return NSImage(data: imageData)
    }
    public static func getAppIcon(forId bundleIdentifier: String = "com.apple.AppStore", appstoreId: String? = nil) async -> Data? {
        // 1️⃣ Try local first
        if let appIcon = getAppIcon(forId: bundleIdentifier, defaultAppStore: false) {
            return appIcon.toPNGData()
        }
        // 2️⃣ If AppStore ID is provided, try online fetch
        if let appstoreId,
           let iconData = await fetchAppIconFromAppStore(appId: appstoreId) {
            return iconData
        }
        // 3️⃣ Fallback, return system default icon
        guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appUrl.path()).toPNGData()
    }
    #elseif canImport(UIKit)
    /// Get local app icon
    public static func getAppIcon(forId: String = "com.apple.AppStore", defaultAppStore: Bool = false) -> UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let image = UIImage(named: lastIcon) {
            return image
        }
        return nil
    }
    @MainActor
    public static func getAppIcon(
        forId bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "com.apple.AppStore",
        appstoreId: String? = nil
    ) async -> UIImage? {
        guard let imageData: Data = await getAppIcon(forId: bundleIdentifier, appstoreId: appstoreId) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    public static func getAppIcon(
        forId bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "com.apple.AppStore",
        appstoreId: String? = nil,
        allowNetwork: Bool = true
    ) async -> Data? {
        // 1️⃣ Try local app icon first
        if let localIcon = getAppIcon(forId: bundleIdentifier, defaultAppStore: false) {
            return localIcon.toData()
        }
        // 2️⃣ If AppStore ID is provided and network is allowed, try online fetch
        if allowNetwork, let appstoreId, !appstoreId.isEmpty,
           let iconData = await fetchAppIconFromAppStore(appId: appstoreId) {
            return iconData
        }
        // 3️⃣ Fallback, return nil
        return nil
    }
    #endif
    // MARK: - Common fetch method
    public static func fetchAppIconFromAppStore(appId: String) async -> Data? {
        let urlString = "https://itunes.apple.com/lookup?id=\(appId)"
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let firstResult = results.first,
                  let iconUrlString = firstResult["artworkUrl512"] as? String,
                  let iconUrl = URL(string: iconUrlString)
            else {
                return nil
            }
            
            let (iconData, _) = try await URLSession.shared.data(from: iconUrl)
            return iconData
            
        } catch {
            return nil
        }
    }
}

public struct MoreAppsView: View {
    @Environment(\.locale) var locale
    public init() {}
    public var body: some View {
        ForEach(MyAppList.apps(), id: \.appId) { app in
            Button(action: {
                app.openApp()
            }, label: {
                MoreAppsLabelView(name: app.name, desc: app.desc ?? "", appId: app.appId, appstoreId: app.appstoreId)
            })
        }
        Divider()
        Button(action: {
            MyAppList.openAppsByMe()
        }, label: {
            HStack {
                Image(systemName: "ellipsis.circle.fill")
                Text("my_other_apps".localized(locale: locale))
            }
        })
    }
}

public struct MoreAppsLabelView: View {
    @Environment(\.locale) var locale
    var name: String
    var desc: String
    var appId: String
    var appstoreId: String
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    var size: Int = 30
    var axis: Axis = .horizontal
#elseif canImport(UIKit)
    var size: Int = 38
    var axis: Axis = .vertical
#endif
    enum Axis {
        case horizontal
        case vertical
    }
    public init(name: String, desc: String, appId: String, appstoreId: String) {
        self.name = name
        self.desc = desc
        self.appId = appId
        self.appstoreId = appstoreId
    }
    public var body: some View {
        if axis == .horizontal {
            HStack {
                MoreAppsIcon(appId: appId, appstoreId: appstoreId, size: size)
                Text(name) + Text(" - ").foregroundStyle(Color.secondary) +
                Text(desc.localized(locale: locale)).foregroundStyle(Color.secondary).font(.system(size: 10))
            }
        }
        if axis == .vertical {
            HStack {
                MoreAppsIcon(appId: appId, appstoreId: appstoreId, size: size)
                VStack(alignment: .leading, spacing: 0) {
                    Text(name)
                    Text(desc.localized(locale: locale))
                        .foregroundStyle(Color.secondary).font(.system(size: 10))
                }
            }
        }
    }
}

private class MoreAppsIconModel: ObservableObject {
    @Published var resizable: Bool = false
}

// MARK: - Icon cache management
private actor IconCache {
    static let shared = IconCache()
    private let cache = NSCache<NSString, NSData>()
    private let loadingKeys = Set<String>()
    
    private init() {
        cache.countLimit = 100 // Maximum 100 icons cache
        cache.totalCostLimit = 30 * 1024 * 1024 // Reduced to 30MB for better memory management
        
        // Configure memory cache
        cache.name = "AppIconCache"
        
        // Setup memory warning observer - using traditional approach to avoid warnings
        #if canImport(UIKit)
        setupMemoryWarningObserver()
        #endif
    }
    
    func getIcon(for key: String) -> Data? {
        if let cachedData = cache.object(forKey: key as NSString) as Data? {
            return cachedData
        }
        return nil
    }
    
    func setIcon(_ data: Data, for key: String) {
        // Use lower cost calculation for better performance
        let cost = min(data.count, 1024 * 1024) // Cap cost at 1MB per item
        cache.setObject(data as NSData, forKey: key as NSString, cost: cost)
    }
    
    func isLoading(key: String) -> Bool {
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
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func clearMemoryCache() {
        cache.removeAllObjects()
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

// MARK: - MoreAppsIcon
public struct MoreAppsIcon: View {
    @ObservedObject private var viewModel: MoreAppsIconModel = .init()
    var appId: String
    var appstoreId: String
    var size: Int = 30
    @State private var nsuiImage: NSUIImage?
    @State private var isLoading: Bool = false
    @State private var loadTask: Task<Void, Never>?
    @State private var hasAttemptedLoad: Bool = false
    
    public init(appId: String, appstoreId: String, size: Int = 30) {
        self.appId = appId
        self.appstoreId = appstoreId
        self.size = size
    }
    private var cacheKey: String {
        return "\(appId)_\(appstoreId)_\(size)~124"
    }
    public var body: some View {
        Group {
            if let icon: NSUIImage = nsuiImage {
                if viewModel.resizable == true {
                    Image(nsuiImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(nsuiImage: icon)
                }
            } else {
                // Show placeholder with minimal state changes
                placeholderView
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
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "app.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: CGFloat(size) * 0.4))
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
        // Prevent duplicate loading
        guard nsuiImage == nil && !isLoading && !hasAttemptedLoad else { return }
        
        // Mark as attempted to prevent re-triggering
        hasAttemptedLoad = true
        
        // Asynchronously check cache and load
        loadTask = Task { @MainActor in
            // 1️⃣ Check cache first (non-blocking)
            if let cachedData: Data = await IconCache.shared.getIcon(for: cacheKey) {
                // Process image on background thread
                let resizedImage = await processImageData(cachedData)
                
                guard !Task.isCancelled else { return }
                
                // Single UI update
                self.nsuiImage = resizedImage
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
                await IconCache.shared.setIcon(iconData, for: cacheKey)
            }
            
            // Process image (background)
            let processedImage = await processImageData(iconData)
            
            guard !Task.isCancelled else {
                self.loadTask = nil
                return
            }
            
            // Single UI update with both state changes
            self.nsuiImage = processedImage
            self.isLoading = false
            self.loadTask = nil
        }
    }
}

public struct MoreAppsMenuView: View {
    @Environment(\.locale) var locale
    public init() {}
    public var body: some View {
        Menu {
            MoreAppsView()
        } label: {
            Text("my_other_apps".localized(locale: locale))
        }
    }
}

public struct MoreAppsCommandMenus<ContentView: View>: Commands {
    @Environment(\.locale) var locale: Locale
    var content: (() -> ContentView)?
    public init(content: (() -> ContentView)?) {
        self.content = content
    }
    public var body: some Commands {
        CommandMenu("more_tools".localized(locale: locale)) {
            Group {
                MoreAppsView()
            }
            .environment(\.locale, locale)
            if let content = self.content {
                content()
            }
        }
    }
}

public extension MoreAppsCommandMenus where ContentView == EmptyView {
    init() {
        self.init(content: nil)
    }
}


#Preview {
    List {
        MoreAppsView()
        MoreAppsMenuView()
        ButtonWebsite(app: MyAppList.appMenuist)
    }
    .padding()
}
