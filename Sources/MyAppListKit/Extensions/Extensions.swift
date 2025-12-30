//
//  Extensions.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public typealias NSUIImage = NSImage
#elseif canImport(UIKit)
public typealias NSUIImage = UIImage
#endif

public extension String {
    static func localized(key: String, bundle: Bundle? = nil, comment: String = "", locale: Locale, _ arguments: any CVarArg...) -> String {
        let bd = bundle ?? .module
        guard let path = bd.path(forResource: locale.identifier, ofType: "lproj"),
              let localeBundle = Bundle(path: path) else {
            let format = NSLocalizedString(key, bundle: bd, comment: comment)
            return String.localizedStringWithFormat(format, arguments)
        }
        let format = NSLocalizedString(key, bundle: localeBundle, comment: comment)
        return String.localizedStringWithFormat(format, arguments)
    }
    static func localized(key: String, bundle: Bundle? = nil, comment: String = "", locale: String, _ arguments: CVarArg...) -> String {
        return self.localized(key: key, bundle: bundle, comment: comment, locale: Locale(identifier: locale), arguments)
    }
    static func localized(key: String, bundle: Bundle? = nil, locale: String, _ arguments: CVarArg...) -> String {
        return self.localized(key: key, bundle: bundle, locale: Locale(identifier: locale), arguments)
    }
    func localized(bundle: Bundle? = nil, comment: String = "") -> String {
        return NSLocalizedString(self, bundle: bundle ?? .module, comment: comment)
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
