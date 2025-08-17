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
        let languagePart = locale.identifier.split(separator: "_").first.map(String.init) ?? ""
        guard let path = Bundle.module.path(forResource: languagePart, ofType: "lproj") else {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle.module, comment: "")
        }
        let languageBundle = Bundle(path: path)
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
