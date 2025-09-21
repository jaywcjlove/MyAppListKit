//
//  MoreToolsView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MoreAppsView: View {
    @Environment(\.locale) var locale
    public init() {}
    public var body: some View {
        ForEach(MyAppList.apps(), id: \.appId) { app in
            Button(action: {
                app.openApp()
            }, label: {
                MoreAppsLabelView(name: app.name, desc: app.desc ?? "", appId: app.appId, appstoreId: app.appstoreId)
            })
        }
        Divider()
        Button(action: {
            MyAppList.openAppsByMe()
        }, label: {
            HStack {
                Image(systemName: "ellipsis.circle.fill")
                Text("my_other_apps".localized(locale: locale))
            }
        })
    }
}

public struct MoreAppsMenuView: View {
    @Environment(\.locale) var locale
    public init() {}
    public var body: some View {
        Menu {
            MoreAppsView()
        } label: {
            Text("my_other_apps".localized(locale: locale))
        }
    }
}

#Preview {
    List {
        MoreAppsView()
        MoreAppsMenuView()
        ButtonWebsite(app: MyAppList.appMenuist)
    }
    .padding()
}
