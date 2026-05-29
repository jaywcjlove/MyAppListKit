//
//  MoreToolsView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MoreAppsView: View {
    @Environment(\.locale) var locale
    private let apps: [MyAppList.AppData]
    private let appsByMeURL: String?

    public init(apps: [MyAppList.AppData], appsByMeURL: String? = nil) {
        self.apps = apps
        self.appsByMeURL = appsByMeURL
    }

    public var body: some View {
        ForEach(apps, id: \.appId) { app in
            Button(action: {
                app.openApp()
            }, label: {
                MoreAppsLabelView(
                    name: app.name,
                    desc: app.desc ?? "",
                    descBundle: app.descBundle,
                    appId: app.appId,
                    appstoreId: app.appstoreId
                )
                .environment(\.locale, locale)
            })
        }
        if let appsByMeURL {
            Divider()
            Button(action: {
                MyAppList.openURL(string: appsByMeURL)
            }, label: {
                HStack {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("my_other_apps", bundle: .module)
                }
                .environment(\.locale, locale)
            })
        }
    }
}

public struct MoreAppsMenuView: View {
    @Environment(\.locale) var locale
    private let apps: [MyAppList.AppData]
    private let appsByMeURL: String?

    public init(apps: [MyAppList.AppData], appsByMeURL: String? = nil) {
        self.apps = apps
        self.appsByMeURL = appsByMeURL
    }

    public var body: some View {
        Menu {
            MoreAppsView(apps: apps, appsByMeURL: appsByMeURL)
        } label: {
            Text("my_other_apps", bundle: .module)
                .environment(\.locale, locale)
        }
    }
}

#Preview {
    let app = MyAppList.AppData(
        name: "Example App",
        appId: "com.example.app",
        appstoreId: "123456789",
        platform: .macOS,
        desc: "example_des"
    )

    List {
        MoreAppsView(apps: [app], appsByMeURL: "https://apps.apple.com/developer/id1714265259")
        MoreAppsMenuView(apps: [app], appsByMeURL: "https://apps.apple.com/developer/id1714265259")
        ButtonWebsite(app: app)
    }
    .padding()
}
