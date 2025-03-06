//
//  CheckForUpdatesView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MyAppCheckForUpdatesView<BeforeView: View, AfterView: View>: View {
    public init(app: MyAppList.AppData, before: BeforeView? = nil, after: AfterView?) {
        self.app = app
    }
    /// chevron.right
    var before: BeforeView?
    var after: AfterView?
    var app: MyAppList.AppData
    public var body: some View {
        Button(action: {
            app.openURL()
        }, label: {
            before
            Text("check_for_updates".localized())
            after
        })
    }
}
