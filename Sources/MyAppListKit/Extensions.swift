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
    func localized( _ arguments: any CVarArg...) -> String {
        return String(format: NSLocalizedString(self, bundle: .module, comment: ""), arguments)
    }
}

internal extension String {
    func localized(locale: Locale = Locale.current) -> String {
        let languageCode = locale.identifier
        guard let path = Bundle.module.path(forResource: languageCode, ofType: "lproj") else {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle.module, value: "", comment: "")
        }
        let languageBundle = Bundle(path: path)
        return NSLocalizedString(self, tableName: nil, bundle: languageBundle ?? Bundle.module, value: "", comment: "")
    }
}
