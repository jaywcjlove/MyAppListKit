//
//  MoreAppsLabelView.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

import SwiftUI

public struct MoreAppsLabelView: View {
    @Environment(\.locale) var locale
    var name: String
    var desc: String
    var appId: String
    var appstoreId: String
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    var size: Int = 30
    var axis: Axis = .horizontal
#elseif canImport(UIKit)
    var size: Int = 38
    var axis: Axis = .vertical
#endif
    public enum Axis {
        case horizontal
        case vertical
    }
    public init(name: String, desc: String, appId: String, appstoreId: String, axis: Axis? = nil) {
        self.name = name
        self.desc = desc
        self.appId = appId
        self.appstoreId = appstoreId
        self.axis = axis ?? .vertical
    }
    public var body: some View {
        if axis == .horizontal {
            HStack {
                MoreAppsIcon(appId: appId, appstoreId: appstoreId, size: size)
                Text(name) + Text(" - ").foregroundStyle(Color.secondary) +
                Text(desc.localized(locale: locale)).foregroundStyle(Color.secondary).font(.system(size: 10))
            }
        }
        if axis == .vertical { // in Menu
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
            MoreAppsIcon(appId: appId, appstoreId: appstoreId, size: size)
            Text(name)
            Text(desc.localized(locale: locale))
                .foregroundStyle(Color.secondary).font(.system(size: 10))
#elseif canImport(UIKit)
            MoreAppsIcon(appId: appId, appstoreId: appstoreId, size: size)
            VStack {
                HStack {
                    Text(name)
                    Spacer()
                }
                HStack {
                    Text(desc.localized(locale: locale))
                        .foregroundStyle(Color.secondary).font(.system(size: 10))
                    Spacer()
                }
            }
#endif
        }
    }
}
