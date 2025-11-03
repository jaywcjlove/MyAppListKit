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
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            /// "macappstore://apps.apple.com/app/id6479819388?action=write-review"
            return "macappstore://apps.apple.com/app/id\(appstoreId)"
            #elseif canImport(UIKit)
            return "itms-apps://apps.apple.com/app/id\(appstoreId)"
            #endif
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
            return "feedback_email_url".localized(locale: locale, arguments: self.name, self.name, content)
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
    
    public static let appKeyzer = AppData(
        name: "Keyzer",
        appId: "com.wangchujiang.keyzer",
        appstoreId: "6500434773",
        platform: .macOS,
        website: "https://wangchujiang.com/keyzer/",
        desc: "keyzer_des"
    )
    
    public static let appVidCrop = AppData(
        name: "VidCrop",
        appId: "com.wangchujiang.vidcrop",
        appstoreId: "6752624705",
        platform: .macOS,
        website: "https://wangchujiang.com/vidcrop/",
        desc: "vidcrop_des"
    )
    
    public static let appVidwall = AppData(
        name: "Vidwall",
        appId: "com.wangchujiang.vidwall",
        appstoreId: "6747587746",
        platform: .macOS,
        website: "https://wangchujiang.com/vidwall/",
        desc: "vidwall_des"
    )

    public static let appMousio = AppData(
        name: "Mousio", appId: "com.wangchujiang.mousio", appstoreId: "6746747327", platform: .macOS,
        website: "https://wangchujiang.com/mousio/", desc: "mousio_des"
    )
    
    public static let appAudioer = AppData(
        name: "Audioer",
        appId: "com.wangchujiang.audioer",
        appstoreId: "6743841447",
        platform: .macOS,
        website: "https://wangchujiang.com/audioer/", desc: "audioer_des"
    )
    
    public static let appMusicer = AppData(
        name: "Musicer",
        appId: "com.wangchujiang.musicer",
        appstoreId: "6745227444",
        platform: .macOS,
        website: "https://wangchujiang.com/musicer/", desc: "musicer_des"
    )
    
    public static let appFileSentinel = AppData(
        name: "File Sentinel", appId: "com.wangchujiang.filesentinel", appstoreId: "6744690194", platform: .macOS,
        website: "https://wangchujiang.com/file-sentinel/", desc: "file_sentinel_des"
    )
    
    public static let appFocusCursor = AppData(
        name: "Focus Cursor", appId: "com.wangchujiang.focuscursor", appstoreId: "6743495172", platform: .macOS,
        website: "https://wangchujiang.com/focus-cursor/", desc: "focus_cursor_des"
    )
    
    public static let appVideoer = AppData(
        name: "Videoer", appId: "com.wangchujiang.videoer", appstoreId: "6742680573", platform: .macOS,
        website: "https://wangchujiang.com/videoer/", desc: "videoer_des"
    )

    public static let appDayBar = AppData(
        name: "DayBar", appId: "com.wangchujiang.daybar", appstoreId: "6739052447", platform: .macOS,
        website: "https://wangchujiang.com/daybar/", desc: "daybar_des"
    )
    public static let appDevTutor = AppData(
        name: "DevTutor for SwiftUI", appId: "com.wangchujiang.SwiftTutorial", appstoreId: "6471227008", platform: .both,
        website: "https://wangchujiang.com/devtutor/", desc: "devtutor_des"
    )
    public static let appDevHub = AppData(
        name: "DevHub", appId: "com.wangchujiang.DevHub", appstoreId: "6476452351", platform: .macOS,
        website: "https://wangchujiang.com/DevHub/", desc: "devhub_des"
    )
    public static let appMenuist = AppData(
        name: "Menuist", appId: "com.wangchujiang.rightmenu-master", appstoreId: "6737160756", platform: .macOS,
        website: "https://wangchujiang.com/rightmenu-master/", desc: "rightmenu_master_des"
    )
    public static let appCopybookGenerator = AppData(
        name: "Copybook Generator", appId: "com.wangchujiang.copybook-generator", appstoreId: "6503953628", platform: .macOS,
        website: "https://wangchujiang.com/copybook-generator/", desc: "copybook_generator_des"
    )
    public static let appWebServe = AppData(
        name: "Web Serve", appId: "com.wangchujiang.serve", appstoreId: "6670167443", platform: .macOS,
        website: "https://wangchujiang.com/web-serve/", desc: "web_serve_des"
    )
    public static let appQuickRSS = AppData(
        name: "Quick RSS", appId: "com.wangchujiang.QuickRSS", appstoreId: "6670696072", platform: .both,
        website: "https://wangchujiang.com/quick-rss/", desc: "quick_rss_des"
    )
    public static let appPasteQuick = AppData(
        name: "PasteQuick", appId: "com.wangchujiang.paste-quick", appstoreId: "6723903021", platform: .macOS,
        website: "https://wangchujiang.com/paste-quick/", desc: "paste_quick_des"
    )
    public static let appRegexMate = AppData(
        name: "RegexMate", appId: "com.wangchujiang.RegexMate", appstoreId: "6479819388", platform: .both,
        website: "https://wangchujiang.com/regex-mate/", desc: "regex_mate_des"
    )
    public static let appResumeRevise = AppData(
        name: "Resume Revise", appId: "com.wangchujiang.ResumeRevise", appstoreId: "6476400184", platform: .macOS,
        website: "https://wangchujiang.com/ResumeRevise/", desc: "resume_revise_des"
    )
    public static let appTimePassage = AppData(
        name: "Time Passage", appId: "com.wangchujiang.LifeCountdownTime", appstoreId: "6479194014", platform: .both,
        website: "https://wangchujiang.com/time-passage/", desc: "time_passage_des"
    )
    public static let appTextSoundSaver = AppData(
        name: "TextSound Saver", appId: "com.wangchujiang.TextSoundSaver", appstoreId: "6478511402", platform: .both,
        website: "https://wangchujiang.com/TextSoundSaver/", desc: "textsound_saver_des"
    )
    public static let appKeyClicker = AppData(
        name: "KeyClicker", appId: "com.wangchujiang.keyclicker", appstoreId: "6740425504", platform: .macOS,
        website: "https://wangchujiang.com/key-clicker/", desc: "key_clicker_des"
    )
    
    public static let appIconizeFolder = AppData(
        name: "Iconize Folder", appId: "com.wangchujiang.IconizeFolder", appstoreId: "6478772538", platform: .macOS,
        website: "https://wangchujiang.com/IconizeFolder/", desc: "iconize_folder_des"
    )
    public static let appCreateCustomSymbols = AppData(
        name: "Create Custom Symbols", appId: "com.wangchujiang.CreateCustomSymbols", appstoreId: "6476924627", platform: .macOS,
        website: "https://wangchujiang.com/create-custom-symbols/", desc: "create_custom_symbols_des"
    )
    public static let appSymbolScribe = AppData(
        name: "Symbol Scribe", appId: "com.wangchujiang.SymbolScribe", appstoreId: "6470879005", platform: .macOS,
        website: "https://wangchujiang.com/symbol-scribe/", desc: "symbol_scribe_des"
    )
    public static let appPaletteGenius = AppData(
        name: "Palette Genius", appId: "com.wangchujiang.PaletteGenius", appstoreId: "6472593276", platform: .macOS,
        website: "https://wangchujiang.com/palette-genius/", desc: "palette_genius_des"
    )
    public static let appIconed = AppData(
        name: "Iconed", appId: "com.wangchujiang.Iconed", appstoreId: "6739444407", platform: .macOS,
        website: "https://wangchujiang.com/iconed/", desc: "iconed_des"
    )

    /// List of all apps
    public static let allApps: [AppData] = [
        appKeyzer,
        appVidCrop,
        appVidwall,
        appMousio,
        appAudioer,
        appMusicer,
        appFileSentinel,
        appFocusCursor,
        appVideoer,
        appDayBar,
        appDevTutor,
        appDevHub,
        appMenuist,
        appCopybookGenerator,
        appWebServe,
        appQuickRSS,
        appPasteQuick,
        appRegexMate,
        appResumeRevise,
        appTimePassage,
        appTextSoundSaver,
        appKeyClicker,
        appIconizeFolder,
        appCreateCustomSymbols,
        appSymbolScribe,
        appPaletteGenius,
        appIconed,
    ]
    /// Bundle identifier of the current app
    public static let bundleIdentifier: String = Bundle.main.bundleIdentifier!
    
    /// Returns a list of apps excluding the current app
    public static func apps() -> [AppData] {
        return MyAppList.allApps.filter { $0.appId != MyAppList.bundleIdentifier }
    }
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Opens the app if installed, otherwise opens the App Store
    public static func openApp(appId: String, appstoreId: String) {
        let appStoreURL = "macappstore://apps.apple.com/app/id\(appstoreId)"
        openApp(appId: appId, urlString: appStoreURL)
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
    #elseif canImport(UIKit)
    /// Opens the app if installed, otherwise opens the App Store
    public static func openApp(appId: String, appstoreId: String) {
        let appStoreURL = "itms-apps://apps.apple.com/app/id\(appstoreId)"
        openApp(appId: appId, urlString: appStoreURL)
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
    
    /// Opens the developer's apps page
    public static func openAppsByMe() {
        openURL(string: appsByMe)
    }
    
    /// Returns the developer's apps page URL based on the platform
    public static var appsByMe: String {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        "macappstore://apps.apple.com/developer/id1714265259"
        #elseif canImport(UIKit)
        "https://apps.apple.com/developer/id1714265259"
        #endif
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
