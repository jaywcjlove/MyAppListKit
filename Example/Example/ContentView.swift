//
//  ContentView.swift
//  Example
//
//  Created by 王楚江 on 2024/11/27.
//

import SwiftUI
import MyAppListKit

struct ContentView: View {
    @Environment(\.locale) var locale
    var body: some View {
        let emailURLString2: String = MyAppList.appDevTutor.sendFeedback(content: MyAppList.version, locale: locale)
        var _ = print("locale:", locale)
        var _ = print("locale.language.languageCode:", locale.language.languageCode?.identifier ?? "nil")
        var _ = print("locale.region:", locale.region?.identifier ?? "nil")
        var _ = print("send_feedback localized:", String.localized(key: "send_feedback", locale: locale))
        var _ = print("emailURLString:", emailURLString2, MyAppList.version)
        List {
            ButtonWebsite(app: MyAppList.appIconizeFolder)
            ButtonRateApp(app: MyAppList.appIconizeFolder)
            ButtonSendFeedback(app: MyAppList.appIconizeFolder)
//            MoreAppsView()
            ForEach(MyAppList.apps(), id: \.appId) { app in
                Button(action: {
                    app.openApp()
                }, label: {
                    MoreAppsLabelView(name: app.name, desc: app.desc ?? "", appId: app.appId, appstoreId: app.appstoreId)
                })
                .buttonStyle(.plain)
            }
        }
        .onDisappear() {
            Task {
                await AppIconCache.shared.clearMemoryCache()
            }
        }
//        ScrollView {
//            VStack(alignment: .leading) {
//                MoreAppsView()
//                MyAppCheckForUpdatesView(app: MyAppList.appIconed)
//            }
//            .padding(.horizontal)
//            .padding(.vertical)
//        }
    }
}
