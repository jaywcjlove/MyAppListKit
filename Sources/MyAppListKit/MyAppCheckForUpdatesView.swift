//
//  CheckForUpdatesView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MyAppCheckForUpdatesView<BeforeView: View, AfterView: View>: View {
    var app: MyAppList.AppData
    var before: BeforeView
    var after: AfterView

    public init(app: MyAppList.AppData, before: BeforeView = EmptyView(), after: AfterView = EmptyView()) {
        self.app = app
        self.before = before
        self.after = after
    }
    public var body: some View {
        Button(action: {
            app.openURL()
        }, label: {
            HStack {
                before
                Text("check_for_updates".localized())
                after
            }
        })
    }
}
