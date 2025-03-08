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
