//
//  MoreToolsView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MoreAppsView: View {
    public init() {}
    public var body: some View {
        ForEach(MyAppList.apps(), id: \.appId) { app in
            Button(app.name, action: {
                app.openApp()
            })
        }
        Button(action: {
            MyAppList.openAppsByMe()
        }, label: {
            HStack {
                Image(systemName: "ellipsis.circle.fill")
                Text("my_other_apps".localized())
            }
        })
    }
}

public struct MoreAppsMenuView: View {
    public init() {}
    public var body: some View {
        Menu {
            MoreAppsView()
        } label: {
            Text("my_other_apps".localized())
        }
    }
}
