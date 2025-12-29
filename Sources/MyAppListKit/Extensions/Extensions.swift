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
    static func localized(key: String, locale: Locale, _ arguments: any CVarArg...) -> String {
        guard let path = Bundle.module.path(forResource: locale.identifier, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            let format = NSLocalizedString(key, bundle: .module, comment: "")
            return String.localizedStringWithFormat(format, arguments)
        }
        let format = NSLocalizedString(key, bundle: bundle, comment: "")
        return String.localizedStringWithFormat(format, arguments)
    }
    
    func localized() -> String {
        return NSLocalizedString(self, bundle: .module, comment: "")
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
