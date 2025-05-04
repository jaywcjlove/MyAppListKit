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
    public static func getAppIcon(forId bundleIdentifier: String = "com.apple.AppStore") -> NSImage? {
        guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return getAppIcon()
        }
        return NSWorkspace.shared.icon(forFile: appUrl.path)
    }
    #elseif os(iOS)
    public static func getAppIcon(forId bundleIdentifier: String = "com.apple.AppStore") -> UIImage? {
        guard let app = Bundle.main.url(forResource: bundleIdentifier, withExtension: "app") else {
            // For system apps, you might need a different approach.
            // This is a basic example for bundled apps.
            return getAppIcon()
        }
        if let bundle = Bundle(url: app), let icons = bundle.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    #endif
}

public struct MoreAppsView: View {
    @Environment(\.locale) var locale
    public init() {}
    public var body: some View {
        ForEach(MyAppList.apps(), id: \.appId) { app in
            Button(action: {
                app.openApp()
            }, label: {
                HStack {
                    if let icon = MyAppList.getAppIcon(forId: app.appId)?.resized(to: .init(width: 18, height: 18)) {
#if os(macOS)
                        Image(nsImage: icon)
#elseif os(iOS)
                        Image(uiImage: icon)
#endif
                    } else if let icon = MyAppList.getAppIcon()?.resized(to: .init(width: 18, height: 18)) {
#if os(macOS)
                        Image(nsImage: icon)
#elseif os(iOS)
                        Image(uiImage: icon)
#endif
                    }
                    Text(app.name) + Text(" - ").foregroundStyle(Color.secondary) +
                    Text(app.desc?.localized(locale: locale) ?? "").foregroundStyle(Color.secondary).font(.system(size: 10))
                }
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
    @Environment(\.locale) var locale
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
    VStack {
        MoreAppsView()
        MoreAppsMenuView()
        ButtonWebsite(app: MyAppList.appRightMenuMaster)
    }
    .padding()
}
