//
//  MoreAppsCommandMenus.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

import SwiftUI

public struct MoreAppsCommandMenus<ContentView: View>: Commands {
    @Environment(\.locale) var locale: Locale
    private let apps: [MyAppList.AppData]
    private let appsByMeURL: String?
    var content: (() -> ContentView)?

    public init(apps: [MyAppList.AppData], appsByMeURL: String? = nil, content: (() -> ContentView)?) {
        self.apps = apps
        self.appsByMeURL = appsByMeURL
        self.content = content
    }

    public var body: some Commands {
        CommandMenu(String.localized(key: "more_tools", locale: locale)) {
            Group {
                MoreAppsView(apps: apps, appsByMeURL: appsByMeURL)
            }
            .environment(\.locale, locale)
            if let content = self.content {
                content()
            }
        }
    }
}

public extension MoreAppsCommandMenus where ContentView == EmptyView {
    init(apps: [MyAppList.AppData], appsByMeURL: String? = nil) {
        self.init(apps: apps, appsByMeURL: appsByMeURL, content: nil)
    }
}
