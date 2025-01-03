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
        public var storeURL: URL {
            #if os(macOS)
            /// "macappstore://apps.apple.com/app/id6479819388?action=write-review"
            return URL(string: "macappstore://apps.apple.com/app/id\(appstoreId)?action=write-review")!
            #endif
            #if os(iOS)
            return URL(string: "itms-apps://apps.apple.com/app/id\(appstoreId)?action=write-review")!
            #endif
        }
        public func openURL() {
            MyAppList.openURL(url: self.storeURL)
        }
        public func openApp() {
            MyAppList.openApp(appId: appId, appstoreId: appstoreId)
        }
        public func appURL() -> URL? {
            #if os(macOS)
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: self.appId)
            #elseif os(iOS)
            return nil
            #endif
        }
    }
    public static let appDevTutor = AppData(name: "DevTutor for SwiftUI", appId: "com.wangchujiang.SwiftTutorial", appstoreId: "6471227008", platform: .both)
    public static let appDevHub = AppData(name: "DevHub", appId: "com.wangchujiang.DevHub", appstoreId: "6476452351", platform: .macOS)
    public static let appRightMenuMaster = AppData(name: "RightMenu Master", appId: "com.wangchujiang.rightmenu-master", appstoreId: "6737160756", platform: .macOS)
    public static let appCopybookGenerator = AppData(name: "Copybook Generator", appId: "com.wangchujiang.copybook-generator", appstoreId: "6503953628", platform: .macOS)
    public static let appCreateCustomSymbols = AppData(name: "Create Custom Symbols", appId: "com.wangchujiang.CreateCustomSymbols", appstoreId: "6476924627", platform: .macOS)
    public static let appWebServe = AppData(name: "Web Serve", appId: "com.wangchujiang.serve", appstoreId: "6670167443", platform: .macOS)
    public static let appQuickRSS = AppData(name: "Quick RSS", appId: "com.wangchujiang.QuickRSS", appstoreId: "6670696072", platform: .both)
    public static let appPasteQuick = AppData(name: "PasteQuick", appId: "com.wangchujiang.paste-quick", appstoreId: "6723903021", platform: .macOS)
    public static let appRegexMate = AppData(name: "RegexMate", appId: "com.wangchujiang.RegexMate", appstoreId: "6479819388", platform: .both)
    public static let appIconizeFolder = AppData(name: "Iconize Folder", appId: "com.wangchujiang.IconizeFolder", appstoreId: "6478772538", platform: .macOS)
    public static let appSymbolScribe = AppData(name: "Symbol Scribe", appId: "com.wangchujiang.SymbolScribe", appstoreId: "6470879005", platform: .macOS)
    public static let appPaletteGenius = AppData(name: "Palette Genius", appId: "com.wangchujiang.PaletteGenius", appstoreId: "6472593276", platform: .macOS)
    public static let appResumeRevise = AppData(name: "Resume Revise", appId: "com.wangchujiang.ResumeRevise", appstoreId: "6476400184", platform: .macOS)
    public static let appTimePassage = AppData(name: "Time Passage", appId: "com.wangchujiang.LifeCountdownTime", appstoreId: "6479194014", platform: .both)
    public static let appTextSoundSaver = AppData(name: "TextSound Saver", appId: "com.wangchujiang.TextSoundSaver", appstoreId: "6478511402", platform: .both)
    public static let appIconed = AppData(name: "Iconed", appId: "com.wangchujiang.Iconed", appstoreId: "6739444407", platform: .macOS)
    public static let allApps: [AppData] = [
        appDevTutor,
        appDevHub,
        appRightMenuMaster,
        appIconed,
        appCopybookGenerator,
        appCreateCustomSymbols,
        appWebServe,
        appQuickRSS,
        appPasteQuick,
        appRegexMate,
        appIconizeFolder,
        appSymbolScribe,
        appPaletteGenius,
        appResumeRevise,
        appTimePassage,
        appTextSoundSaver,
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
                        openURL(url: appStoreURL)
                    }
                }
            } else {
                openURL(url: appStoreURL)
            }
        } else {
            // 应用未安装，打开 App Store
            if let appStoreURL = URL(string: appStoreURL) {
                openURL(url: appStoreURL)
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
                        openURL(url: appStoreURL)
                    } else {
                        print("无法打开 URL: \(appStoreURL)")
                    }
                }
            }
        }
    }
    #endif
    public static func openURL(url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #endif
        #if os(iOS)
        Task {
            await UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        #endif
    }
    
    public static func openURL(string: String) {
        if let url = URL(string: string) {
            openURL(url: url)
        }
    }
    
    public static func openAppsByMe() {
        openURL(string: appsByMe)
    }
    
    public static var appsByMe: String {
        #if os(macOS)
        "macappstore://apps.apple.com/developer/id1714265259"
        #elseif os(iOS)
        "https://apps.apple.com/developer/id1714265259"
        #endif
    }
}
