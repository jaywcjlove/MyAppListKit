//
//  MoreToolsView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

#if os(macOS)
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
}
#endif

#if os(iOS)
extension UIImage {
    public func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
#endif

extension MyAppList {
    #if os(macOS)
    /// 获取本地应用图标
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
        // 1️⃣ 本地优先
        if let appIcon = getAppIcon(forId: bundleIdentifier, defaultAppStore: false) {
            return appIcon
        }
        // 2️⃣ 如果提供了 AppStore ID，尝试在线获取
        if let appstoreId,
           let iconData = await fetchAppIconFromAppStore(appId: appstoreId) {
            return NSImage(data: iconData)
        }
        // 3️⃣ fallback，返回系统默认 icon
        guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appUrl.path)
    }
    #elseif os(iOS)
    /// 获取本地应用图标
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
        // 1️⃣ 本地优先
        if let appIcon = getAppIcon(forId: bundleIdentifier, defaultAppStore: false) {
            return appIcon
        }

        // 2️⃣ 如果提供了 AppStore ID，尝试在线获取
        if let appstoreId,
           let iconData = await fetchAppIconFromAppStore(appId: appstoreId) {
            return UIImage(data: iconData)
        }
        // 3️⃣ fallback，返回空或默认图标
        return nil
    }
    #endif
    // MARK: - 公共 fetch 方法
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
    public var body: some View {
        HStack {
            MoreAppsIcon(appId: appId, appstoreId: appstoreId)
            Text(name) + Text(" - ").foregroundStyle(Color.secondary) +
            Text(desc.localized(locale: locale)).foregroundStyle(Color.secondary).font(.system(size: 10))
        }
    }
}


public struct MoreAppsIcon: View {
    var appId: String
    var appstoreId: String
#if os(macOS)
    @State var nsImage: NSImage? = MyAppList.getAppIcon()
#elseif os(iOS)
    @State var nsImage: UIImage? = nil
#endif
    public init(appId: String, appstoreId: String) {
        self.appId = appId
        self.appstoreId = appstoreId
    }
    public var body: some View {
        Group {
            if let icon = nsImage?.resized(to: .init(width: 30, height: 30)) {
#if os(macOS)
                Image(nsImage: icon)
#elseif os(iOS)
                Image(uiImage: icon)
#endif
            }
        }
        .onAppear() {
            Task {
                if let icon = await MyAppList.getAppIcon(forId: appId, appstoreId: appstoreId)?.resized(to: .init(width: 62, height: 62)) {
                    DispatchQueue.main.async {
                        self.nsImage = icon
                    }
                }
            }
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
