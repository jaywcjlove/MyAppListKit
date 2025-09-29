//
//  MyAppList+AppIcon.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
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
    public static func getAppIcon(
        forId bundleIdentifier: String = "com.apple.AppStore",
        appstoreId: String? = nil,
        scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 2.0
    ) async -> NSImage? {
        guard let imageData: Data = await getAppIcon(forId: bundleIdentifier, appstoreId: appstoreId) else { return nil }
        return NSImage(data: imageData)
    }
    public static func getAppIcon(
        forId bundleIdentifier: String = "com.apple.AppStore",
        appstoreId: String? = nil,
        scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 2.0
    ) async -> Data? {
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
