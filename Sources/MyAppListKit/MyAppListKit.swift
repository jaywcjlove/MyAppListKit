// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#elseif canImport(WatchKit)
import WatchKit
#endif

public struct MyAppList {
    public struct AppData: Sendable {
        public let name: String
        public let appId: String
        public let appstoreId: String
        public let platform: Platform

        public init(name: String, appId: String, appstoreId: String, platform: Platform) {
            self.name = name
            self.appId = appId
            self.appstoreId = appstoreId
            self.platform = platform
        }

        public enum Platform: Sendable {
            case iOS
            case macOS
            /// 两个平台都支持
            case both
        }
    }
    static let allApps: [AppData] = [
        AppData(name: "DevTutor for SwiftUI", appId: "com.wangchujiang.SwiftTutorial", appstoreId: "6471227008", platform: .macOS),
        AppData(name: "DevHub", appId: "com.wangchujiang.DevHub", appstoreId: "6476452351", platform: .macOS),
        AppData(name: "RightMenu Master", appId: "com.wangchujiang.rightmenu-master", appstoreId: "6737160756", platform: .macOS),
        AppData(name: "Copybook Generator", appId: "com.wangchujiang.copybook-generator", appstoreId: "6503953628", platform: .macOS),
        AppData(name: "Create Custom Symbols", appId: "com.wangchujiang.CreateCustomSymbols", appstoreId: "6476924627", platform: .macOS),
        AppData(name: "Web Serve", appId: "com.wangchujiang.serve", appstoreId: "6670167443", platform: .macOS),
        AppData(name: "Quick RSS", appId: "com.wangchujiang.QuickRSS", appstoreId: "6670696072", platform: .macOS),
        AppData(name: "PasteQuick", appId: "com.wangchujiang.paste-quick", appstoreId: "6723903021", platform: .macOS),
        AppData(name: "RegexMate", appId: "com.wangchujiang.RegexMate", appstoreId: "6479819388", platform: .macOS),
        AppData(name: "Iconize Folder", appId: "com.wangchujiang.IconizeFolder", appstoreId: "6478772538", platform: .macOS),
        AppData(name: "Symbol Scribe", appId: "com.wangchujiang.SymbolScribe", appstoreId: "6470879005", platform: .macOS),
        AppData(name: "Palette Genius", appId: "com.wangchujiang.PaletteGenius", appstoreId: "6472593276", platform: .macOS),
        AppData(name: "Resume Revise", appId: "com.wangchujiang.ResumeRevise", appstoreId: "6476400184", platform: .macOS),
        AppData(name: "Time Passage", appId: "com.wangchujiang.LifeCountdownTime", appstoreId: "6479194014", platform: .macOS),
        AppData(name: "TextSound Saver", appId: "com.wangchujiang.TextSoundSaver", appstoreId: "6478511402", platform: .macOS),
    ]
    
    public static let bundleIdentifier: String = Bundle.main.bundleIdentifier!
    
    public static func apps() -> [AppData] {
        return MyAppList.allApps.filter { $0.appId != MyAppList.bundleIdentifier }
    }
    #if os(macOS)
    public static func openApp(appId: String, appstoreId: String) {
        let appStoreURL = "macappstore://apps.apple.com/app/id\(appstoreId)"
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appId), let appStoreURL = URL(string: appStoreURL) {
            if #available(macOS 10.15, *) {
                let configuration = NSWorkspace.OpenConfiguration()
                NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
                    if let error = error {
                        NSWorkspace.shared.open(appStoreURL)
                    }
                }
            } else {
                NSWorkspace.shared.open(appStoreURL)
            }
        } else {
            // 应用未安装，打开 App Store
            if let appStoreURL = URL(string: appStoreURL) {
                NSWorkspace.shared.open(appStoreURL)
            }
        }
    }
    #endif
    #if os(iOS)
    public static func openApp(appId: String, appstoreId: String) {
        let appStoreURL = "itms-apps://apps.apple.com/app/id\(appstoreId)"
        if let appStoreURL = URL(string: appStoreURL) {
            // 打开 App Store 或使用 URL 方案打开其他应用
            if #available(iOS 13.0, *) {
                Task {
                    if await UIApplication.shared.canOpenURL(appStoreURL) {
                        await UIApplication.shared.open(appStoreURL, options: [:], completionHandler: { error in
                            print("Error opening App Store: \(error.description)")
                        })
                    } else {
                        print("无法打开 URL: \(appStoreURL)")
                    }
                }
            }
        }
    }
    #endif
}



