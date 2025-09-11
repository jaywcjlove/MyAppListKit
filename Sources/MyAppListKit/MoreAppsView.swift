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
        return NSImage(size: newSize, flipped: false) { rect in
            self.draw(in: rect,
                      from: NSRect(origin: CGPoint.zero, size: self.size),
                      operation: NSCompositingOperation.copy,
                      fraction: 1.0)
            return true
        }
    }
    func toData() -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        let imageFileType: NSBitmapImageRep.FileType = .png
        return bitmapImageRep.representation(using: imageFileType, properties: [:])
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
            return appIcon.toData()
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
        return NSWorkspace.shared.icon(forFile: appUrl.path()).toData()
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
        appstoreId: String? = nil
    ) async -> Data? {
        // 2️⃣ If AppStore ID is provided, try online fetch
        if let appstoreId,
           let iconData = await fetchAppIconFromAppStore(appId: appstoreId) {
            return iconData
        }
        // 3️⃣ Fallback, return nil or default icon
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
    private let diskCacheURL: URL
    
    private init() {
        cache.countLimit = 100 // Maximum 100 icons cache
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        // Set disk cache path
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDir.appendingPathComponent("AppIcons")
        
        // Create cache directory
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        // Configure memory cache
        cache.name = "AppIconCache"
        
        // Setup memory warning observer - using traditional approach to avoid warnings
        #if canImport(UIKit)
        setupMemoryWarningObserver()
        #endif
    }
    
    func getIcon(for key: String) -> Data? {
        // Check memory cache first
        if let cachedData = cache.object(forKey: key as NSString) as Data? {
            return cachedData
        }
        
        // Check disk cache
        let fileURL = diskCacheURL.appendingPathComponent("\(key.hash).png")
        if let diskData = try? Data(contentsOf: fileURL) {
            // Load disk data into memory cache
            cache.setObject(diskData as NSData, forKey: key as NSString, cost: diskData.count)
            return diskData
        }
        
        return nil
    }
    
    func setIcon(_ data: Data, for key: String) {
        // Save to memory cache
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        // Asynchronously save to disk cache
        Task.detached(priority: .utility) {
            let fileURL = self.diskCacheURL.appendingPathComponent("\(key.hash).png")
            try? data.write(to: fileURL)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? FileManager.default.removeItem(at: diskCacheURL)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
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

public struct MoreAppsIcon: View {
    @ObservedObject private var viewModel: MoreAppsIconModel = .init()
    var appId: String
    var appstoreId: String
    var size: Int = 30
    @State private var nsuiImage: NSUIImage?
    @State private var isLoading: Bool = false
    @State private var loadTask: Task<Void, Never>?
    
    public init(appId: String, appstoreId: String, size: Int = 30) {
        self.appId = appId
        self.appstoreId = appstoreId
        self.size = size
    }
    
    private var cacheKey: String {
        return "\(appId)_\(appstoreId)_\(size)"
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
                // Show placeholder
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
        }
        .frame(width: CGFloat(size), height: CGFloat(size))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onAppear {
            loadIconIfNeeded()
        }
        .onDisappear {
            cancelLoading()
        }
        .id(cacheKey) // Ensure reload when cache key changes
    }
    
    private func loadIconIfNeeded() {
        // Prevent duplicate loading
        guard nsuiImage == nil && !isLoading else { return }
        
        // Asynchronously check cache and load
        loadTask = Task {
            // 1️⃣ Check cache first
            if let cachedData = await IconCache.shared.getIcon(for: cacheKey) {
                // Process image on background thread
                let resizedImage = await processImageData(cachedData)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.nsuiImage = resizedImage
                }
                return
            }
            
            // 2️⃣ No cache available, start loading
            await MainActor.run {
                self.isLoading = true
            }
            
            // Get icon data
            let iconData = await MyAppList.getAppIcon(forId: appId, appstoreId: appstoreId) as Data?
            
            guard !Task.isCancelled, let iconData = iconData else {
                await MainActor.run {
                    self.isLoading = false
                    self.loadTask = nil
                }
                return
            }
            
            // Save to cache
            await IconCache.shared.setIcon(iconData, for: cacheKey)
            
            // Process image
            let processedImage = await processImageData(iconData)
            
            guard !Task.isCancelled else {
                await MainActor.run {
                    self.loadTask = nil
                }
                return
            }
            
            // Update UI
            await MainActor.run {
                self.nsuiImage = processedImage
                self.isLoading = false
                self.loadTask = nil
            }
        }
    }
    
    private func processImageData(_ data: Data) async -> NSUIImage? {
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                let result: NSUIImage? = autoreleasepool {
                    guard let image = NSUIImage(data: data) else { return nil }
                    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
                    let targetSize = NSSize(width: size, height: size)
                    #else
                    let targetSize = CGSize(width: size, height: size)
                    #endif
                    return image.resized(to: targetSize)
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    private func cancelLoading() {
        loadTask?.cancel()
        loadTask = nil
        isLoading = false
    }
    
    public func resizable() -> some View {
        let view = self
        view.viewModel.resizable = true
        return view
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
