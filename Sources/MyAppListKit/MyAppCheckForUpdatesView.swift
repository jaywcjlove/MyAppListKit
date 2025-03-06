//
//  CheckForUpdatesView.swift
//  MyAppListKit
//
//  Created by 王楚江 on 2025/3/6.
//

import SwiftUI

public struct MyAppCheckForUpdatesView<ContentView: View>: View {
    var app: MyAppList.AppData
    var content: ((String) -> ContentView)?

    public init(app: MyAppList.AppData, content: ((String) -> ContentView)? = nil) {
        self.app = app
        self.content = content
    }

    public var body: some View {
        Button(action: {
            app.openURL()
        }, label: {
            if let content = content {
                content("check_for_updates".localized())
            } else {
                Text("check_for_updates".localized())
            }
        })
    }
}
