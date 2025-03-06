//
//  CheckForUpdatesView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MyAppCheckForUpdatesView: View {
    public init(app: MyAppList.AppData) {
        self.app = app
    }
    var app: MyAppList.AppData
    public var body: some View {
        Button(action: {
            app.openURL()
        }, label: {
            Text("check_for_updates".localized())
        })
    }
}
