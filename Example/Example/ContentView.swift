//
//  ContentView.swift
//  Example
//
//  Created by 王楚江 on 2024/11/27.
//

import SwiftUI
import MyAppListKit

struct ContentView: View {
    var body: some View {
        List {
            ForEach(MyAppList.apps(), id: \.appId) { app in
                Button(app.name, action: {
                    MyAppList.openApp(appId: app.appId, appstoreId: app.appstoreId)
                })
            }
        }
        .padding()
    }
}
