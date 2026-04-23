//
//  RateApp.swift
//  MyAppListKit
//
//  Created by wong on 3/18/25.
//

import SwiftUI

public struct ButtonRateApp: View {
    @Environment(\.locale) var locale
    var app: MyAppList.AppData
    public init(app: MyAppList.AppData) {
        self.app = app
    }
    public var body: some View {
        Button(action: app.openWriteReviewURL, label: {
            Text("rate_app", bundle: .module)
                .environment(\.locale, locale)
        })
    }
}

#Preview {
    let app = MyAppList.AppData(
        name: "Example App",
        appId: "com.example.app",
        appstoreId: "123456789",
        platform: .macOS
    )

    ButtonRateApp(app: app)
        .padding()
}
