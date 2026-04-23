//
//  ContentView.swift
//  Example
//
//  Created by 王楚江 on 2024/11/27.
//

import SwiftUI
import MyAppListKit
import MyAppListKitApps

struct ContentView: View {
    @Environment(\.locale) var locale
    var body: some View {
        let emailURLString2: String = MyAppListApps.appDevTutor.sendFeedback(content: MyAppList.version, locale: locale)
        var _ = print("locale:", locale)
        var _ = print("locale.language.languageCode:", locale.language.languageCode?.identifier ?? "nil")
        var _ = print("locale.region:", locale.region?.identifier ?? "nil")
        var _ = print("send_feedback localized:", String.localized(key: "send_feedback", locale: locale))
        var _ = print("emailURLString:", emailURLString2, MyAppList.version)
        List {
            ButtonWebsite(app: MyAppListApps.appIconizeFolder)
            ButtonRateApp(app: MyAppListApps.appIconizeFolder)
            ButtonSendFeedback(app: MyAppListApps.appIconizeFolder)
//            MoreAppsView()
            ForEach(MyAppListApps.apps(), id: \.appId) { app in
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
//                MoreAppsView(apps: MyAppListApps.apps(), appsByMeURL: MyAppListApps.appsByMe)
//                MyAppCheckForUpdatesView(app: MyAppListApps.appIconed)
//            }
//            .padding(.horizontal)
//            .padding(.vertical)
//        }
    }
}
