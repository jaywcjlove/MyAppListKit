//
//  Extensions.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import Foundation

public extension String {
    func localized() -> String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
    func localized(locale: Locale = Locale.current) -> String {
        let languageCode = locale.identifier
        guard let path = Bundle.module.path(forResource: languageCode, ofType: "lproj") else {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle.module, comment: "")
        }
        let languageBundle = Bundle(path: path)
        return NSLocalizedString(self, bundle: languageBundle ?? .module, comment: "")
    }
    func localized(arguments: any CVarArg...) -> String {
        return String(format: NSLocalizedString(self, bundle: .module, comment: ""), arguments)
    }
}

internal extension String {
    func localized(locale: Locale = Locale.current, arguments: any CVarArg...) -> String {
        let languageCode = locale.identifier
        guard let path = Bundle.module.path(forResource: languageCode, ofType: "lproj") else {
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
