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
        public let desc: String?

        public init(name: String, appId: String, appstoreId: String, platform: Platform, website: String? = nil, desc: String? = nil) {
            self.name = name
            self.appId = appId
            self.appstoreId = appstoreId
            self.website = website
            self.platform = platform
            self.desc = desc
        }

        public enum Platform: Sendable {
            case iOS
            case macOS
            /// Supports both platforms
            case both
        }
        /// Returns the store URL for the app based on the platform
        @available(iOS, deprecated: 17.0, message: "Use appStoreWriteReview instead")
        @available(macOS, deprecated: 14.0, message: "Use appStoreWriteReview instead")
        public var storeURLString: String {
            return "\(appStoreURLString)?action=write-review"
        }
        /// Returns the store URL for the app based on the platform
        public var appStoreWriteReview: String {
            return "\(appStoreURLString)?action=write-review"
        }
        public var appStoreURLString: String {
            return appStoreURL + appstoreId
        }
        /// Only supported on macOS
        public var isAppInstalled: Bool {
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            return NSWorkspace.shared.urlForApplication(withBundleIdentifier: self.appId) != nil
            #elseif canImport(UIKit)
            return false
            #endif
        }
        public func sendFeedback(content: String = "", locale: Locale = Locale.current) -> URL {
            return URL(string: sendFeedback(content: content, locale: locale))!
        }
        public func sendFeedback(content: String = "", locale: Locale = Locale.current) -> String {
            return String.localized(key: "feedback_email_url", locale: locale, self.name, self.name, content)
        }
        public var storeURL: URL {
            return URL(string: appStoreURLString)!
        }
        /// Opens the store URL for the app
        public func openURL() {
            MyAppList.openURL(url: self.storeURL)
        }
        /// Opens the store URL for the app
        public func openWriteReviewURL() {
            MyAppList.openURL(string: self.appStoreWriteReview)
        }
        /// Opens the app if installed, otherwise opens the App Store
        public func openApp() {
            MyAppList.openApp(appId: appId, appstoreId: appstoreId)
        }
        /// Returns the URL for the installed app, if available
        public func appURL() -> URL? {
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: self.appId)
            #elseif canImport(UIKit)
            return nil
            #endif
        }
    }
    /// Bundle identifier of the current app
    public static let bundleIdentifier: String = Bundle.main.bundleIdentifier!
    
    /// Returns a list of apps excluding the current app
    public static func apps(from apps: [AppData]) -> [AppData] {
        return apps.filter { $0.appId != MyAppList.bundleIdentifier }
    }
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Opens the app if installed, otherwise opens the App Store
    public static func openApp(appId: String, appstoreId: String) {
        openApp(appId: appId, urlString: appStoreURL + appstoreId)
    }
    public static func openApp(appId: String, urlString: String) {
        let appStoreURL = urlString
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appId), let appStoreURL = URL(string: appStoreURL) {
            if #available(macOS 10.15, *) {
                let configuration = NSWorkspace.OpenConfiguration()
                NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
                    if error != nil {
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
    public static let appStoreURL: String = "macappstore://apps.apple.com/app/id"
    #elseif canImport(UIKit)
    public static let appStoreURL: String = "itms-apps://apps.apple.com/app/id"
    /// Opens the app if installed, otherwise opens the App Store
    public static func openApp(appId: String, appstoreId: String) {
        openApp(appId: appId, urlString: appStoreURL + appstoreId)
    }
    public static func openApp(appId: String, urlString: String) {
        let appStoreURL = urlString
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
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSWorkspace.shared.open(url)
        #elseif canImport(UIKit)
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
    
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Checks if the app is installed
    public static func isAppInstalled(appId: String) -> Bool {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        return apps.contains { $0.bundleIdentifier == appId }
    }
    #elseif canImport(UIKit)
    /// Checks if the app is installed
    @MainActor public static func isAppInstalled(appId: String) -> Bool {
        if let url = URL(string: "\(appId)://") {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    #endif
}
