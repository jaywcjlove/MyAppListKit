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
    /// The version number of the current application
    public static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    public struct AppData: Sendable {
        public let name: String
        public let appId: String
        public let appstoreId: String
        public let platform: Platform
        public let divider: Bool = false
        public let website: String?

        public init(name: String, appId: String, appstoreId: String, platform: Platform, website: String? = nil) {
            self.name = name
            self.appId = appId
            self.appstoreId = appstoreId
            self.website = website
            self.platform = platform
        }

        public enum Platform: Sendable {
            case iOS
            case macOS
            /// Supports both platforms
            case both
        }
        /// Returns the store URL for the app based on the platform
        public var storeURLString: String {
            #if os(macOS)
            /// "macappstore://apps.apple.com/app/id6479819388?action=write-review"
            return "macappstore://apps.apple.com/app/id\(appstoreId)?action=write-review"
            #endif
            #if os(iOS)
            return "itms-apps://apps.apple.com/app/id\(appstoreId)?action=write-review"
            #endif
        }
        public func sendFeedback(content: String = "", locale: Locale = Locale.current) -> URL {
            return URL(string: sendFeedback(content: content))!
        }
        public func sendFeedback(content: String = "", locale: Locale = Locale.current) -> String {
            return "feedback_email_url".localized(locale: locale, arguments: self.name, self.name, content)
        }
        public var storeURL: URL {
            return URL(string: storeURLString)!
        }
        /// Opens the store URL for the app
        public func openURL() {
            MyAppList.openURL(url: self.storeURL)
        }
        /// Opens the app if installed, otherwise opens the App Store
        public func openApp() {
            MyAppList.openApp(appId: appId, appstoreId: appstoreId)
        }
        /// Returns the URL for the installed app, if available
        public func appURL() -> URL? {
            #if os(macOS)
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: self.appId)
            #elseif os(iOS)
            return nil
            #endif
        }
    }
    
    public static let appVideoer = AppData(
        name: "Videoer", appId: "com.wangchujiang.videoer", appstoreId: "6742680573", platform: .macOS,
        website: "https://wangchujiang.com/videoer/"
    )

    public static let appDayBar = AppData(
        name: "DayBar", appId: "com.wangchujiang.daybar", appstoreId: "6739052447", platform: .macOS,
        website: "https://wangchujiang.com/daybar/"
    )
    public static let appDevTutor = AppData(
        name: "DevTutor for SwiftUI", appId: "com.wangchujiang.SwiftTutorial", appstoreId: "6471227008", platform: .both,
        website: "https://wangchujiang.com/devtutor/"
    )
    public static let appDevHub = AppData(
        name: "DevHub", appId: "com.wangchujiang.DevHub", appstoreId: "6476452351", platform: .macOS,
        website: "https://wangchujiang.com/DevHub/"
    )
    public static let appRightMenuMaster = AppData(
        name: "RightMenu Master", appId: "com.wangchujiang.rightmenu-master", appstoreId: "6737160756", platform: .macOS,
        website: "https://wangchujiang.com/rightmenu-master/"
    )
    public static let appCopybookGenerator = AppData(
        name: "Copybook Generator", appId: "com.wangchujiang.copybook-generator", appstoreId: "6503953628", platform: .macOS,
        website: "https://wangchujiang.com/copybook-generator/"
    )
    public static let appWebServe = AppData(
        name: "Web Serve", appId: "com.wangchujiang.serve", appstoreId: "6670167443", platform: .macOS,
        website: "https://wangchujiang.com/web-serve/"
    )
    public static let appQuickRSS = AppData(
        name: "Quick RSS", appId: "com.wangchujiang.QuickRSS", appstoreId: "6670696072", platform: .both,
        website: "https://wangchujiang.com/quick-rss/"
    )
    public static let appPasteQuick = AppData(
        name: "PasteQuick", appId: "com.wangchujiang.paste-quick", appstoreId: "6723903021", platform: .macOS,
        website: "https://wangchujiang.com/paste-quick/"
    )
    public static let appRegexMate = AppData(
        name: "RegexMate", appId: "com.wangchujiang.RegexMate", appstoreId: "6479819388", platform: .both,
        website: "https://wangchujiang.com/regex-mate/"
    )
    public static let appResumeRevise = AppData(
        name: "Resume Revise", appId: "com.wangchujiang.ResumeRevise", appstoreId: "6476400184", platform: .macOS,
        website: "https://wangchujiang.com/ResumeRevise/"
    )
    public static let appTimePassage = AppData(
        name: "Time Passage", appId: "com.wangchujiang.LifeCountdownTime", appstoreId: "6479194014", platform: .both,
        website: "https://wangchujiang.com/time-passage/"
    )
    public static let appTextSoundSaver = AppData(
        name: "TextSound Saver", appId: "com.wangchujiang.TextSoundSaver", appstoreId: "6478511402", platform: .both,
        website: "https://wangchujiang.com/TextSoundSaver/"
    )
    public static let appKeyClicker = AppData(
        name: "KeyClicker", appId: "com.wangchujiang.keyclicker", appstoreId: "6740425504", platform: .macOS,
        website: "https://wangchujiang.com/key-clicker/"
    )
    
    public static let appIconizeFolder = AppData(
        name: "Iconize Folder", appId: "com.wangchujiang.IconizeFolder", appstoreId: "6478772538", platform: .macOS,
        website: "https://wangchujiang.com/IconizeFolder/"
    )
    public static let appCreateCustomSymbols = AppData(
        name: "Create Custom Symbols", appId: "com.wangchujiang.CreateCustomSymbols", appstoreId: "6476924627", platform: .macOS,
        website: "https://wangchujiang.com/create-custom-symbols/"
    )
    public static let appSymbolScribe = AppData(
        name: "Symbol Scribe", appId: "com.wangchujiang.SymbolScribe", appstoreId: "6470879005", platform: .macOS,
        website: "https://wangchujiang.com/symbol-scribe/"
    )
    public static let appPaletteGenius = AppData(
        name: "Palette Genius", appId: "com.wangchujiang.PaletteGenius", appstoreId: "6472593276", platform: .macOS,
        website: "https://wangchujiang.com/palette-genius/"
    )
    public static let appIconed = AppData(
        name: "Iconed", appId: "com.wangchujiang.Iconed", appstoreId: "6739444407", platform: .macOS,
        website: "https://wangchujiang.com/iconed/"
    )

    /// List of all apps
    public static let allApps: [AppData] = [
        appDayBar,
        appDevTutor,
        appDevHub,
        appRightMenuMaster,
        
        appIconizeFolder,
        appCreateCustomSymbols,
        appSymbolScribe,
        appPaletteGenius,
        appIconed,
        
        appVideoer,
        
        appKeyClicker,
        appCopybookGenerator,
        appWebServe,
        appQuickRSS,
        appPasteQuick,
        appRegexMate,
        appResumeRevise,
        appTimePassage,
        appTextSoundSaver,
    ]
    /// Bundle identifier of the current app
    public static let bundleIdentifier: String = Bundle.main.bundleIdentifier!
    
    /// Returns a list of apps excluding the current app
    public static func apps() -> [AppData] {
        return MyAppList.allApps.filter { $0.appId != MyAppList.bundleIdentifier }
    }
    #if os(macOS)
    /// Opens the app if installed, otherwise opens the App Store
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
            /// App not installed, open App Store
            if let appStoreURL = URL(string: appStoreURL) {
                openURL(url: appStoreURL)
            }
        }
    }
    #endif
    #if os(iOS)
    /// Opens the app if installed, otherwise opens the App Store
    public static func openApp(appId: String, appstoreId: String) {
        let appStoreURL = "itms-apps://apps.apple.com/app/id\(appstoreId)"
        if let appStoreURL = URL(string: appStoreURL) {
            // Open App Store or use URL scheme to open other apps
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
    /// Opens the given URL
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
    
    /// Opens the URL from the given string
    public static func openURL(string: String) {
        if let url = URL(string: string) {
            openURL(url: url)
        }
    }
    
    /// Opens the developer's apps page
    public static func openAppsByMe() {
        openURL(string: appsByMe)
    }
    
    /// Returns the developer's apps page URL based on the platform
    public static var appsByMe: String {
        #if os(macOS)
        "macappstore://apps.apple.com/developer/id1714265259"
        #elseif os(iOS)
        "https://apps.apple.com/developer/id1714265259"
        #endif
    }
    
    
    #if os(macOS)
    /// Checks if the app is installed
    public static func isAppInstalled(appId: String) -> Bool {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        return apps.contains { $0.bundleIdentifier == appId }
    }
    #endif
    #if os(iOS)
    /// Checks if the app is installed
    @MainActor public static func isAppInstalled(appId: String) -> Bool {
        if let url = URL(string: "\(appId)://") {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    #endif
}
