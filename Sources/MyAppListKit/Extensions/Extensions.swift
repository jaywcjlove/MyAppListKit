//
//  Extensions.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import Foundation
import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public typealias NSUIImage = NSImage
#elseif canImport(UIKit)
public typealias NSUIImage = UIImage
#endif

public extension String {
    func localized() -> String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
    func localized(locale: Locale = Locale.current) -> String {
        localized(locale: locale, arguments: [])
    }
    func localized(arguments: any CVarArg...) -> String {
        return String(format: NSLocalizedString(self, bundle: .module, comment: ""), arguments)
    }
}

internal extension String {
    func localized(locale: Locale = Locale.current, arguments: any CVarArg...) -> String {
        // 获取语言和地区代码
        let languageCode = locale.language.languageCode?.identifier ?? ""
        let regionCode = locale.region?.identifier ?? ""
        
        // 根据地区代码映射到对应的语言
        var targetLanguage = languageCode
        
        // 地区代码到语言的映射
        let regionToLanguageMap: [String: String] = [
            // 中文地区
            "CN": "zh-Hans",    // 中国大陆 -> 简体中文
            "SG": "zh-Hans",    // 新加坡 -> 简体中文
            "TW": "zh-Hant",    // 台湾 -> 繁体中文
            "HK": "zh-Hant",    // 香港 -> 繁体中文
            "MO": "zh-Hant",    // 澳门 -> 繁体中文
            
            // 其他语言地区
            "JP": "ja",         // 日本 -> 日语
            "KR": "ko",         // 韩国 -> 韩语
            "DE": "de",         // 德国 -> 德语
            "AT": "de",         // 奥地利 -> 德语
            "CH": "de",         // 瑞士 -> 德语（部分地区）
            "FR": "fr",         // 法国 -> 法语
            "BE": "fr",         // 比利时 -> 法语（部分地区）
            "CA": "fr",         // 加拿大 -> 法语（部分地区）
        ]
        
        // 首先检查地区映射
        if let mappedLanguage = regionToLanguageMap[regionCode] {
            targetLanguage = mappedLanguage
        } else if languageCode == "zh" {
            // 如果语言是中文但地区没有映射，默认简体中文
            targetLanguage = "zh-Hans"
        }
        
        // 尝试寻找本地化文件，按优先级查找：
        // 1. 地区映射的语言（如 zh-Hans, zh-Hant）
        // 2. 原始语言代码（如 en, fr, de 等）
        // 3. 英文作为后备
        var path = Bundle.module.path(forResource: targetLanguage, ofType: "lproj")
        
        if path == nil && targetLanguage != languageCode {
            path = Bundle.module.path(forResource: languageCode, ofType: "lproj")
        }
        
        if path == nil && targetLanguage != "en" && languageCode != "en" {
            path = Bundle.module.path(forResource: "en", ofType: "lproj")
        }
        
        guard let validPath = path else {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle.module, comment: "")
        }
        
        let languageBundle = Bundle(path: validPath)
        let localizedString = NSLocalizedString(self, tableName: nil, bundle: languageBundle ?? Bundle.module, comment: "")
        
        if arguments.count > 0 {
            return String(format: localizedString, arguments)
        }
        return localizedString
    }
}


extension Image {
    public init(nsuiImage: NSUIImage) {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        self.init(nsImage: nsuiImage)
#elseif canImport(UIKit)
        self.init(uiImage: nsuiImage)
#endif
    }
}
