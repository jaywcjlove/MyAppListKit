//
//  ButtonWebsite.swift
//  MyAppListKit
//
//  Created by wong on 3/18/25.
//

import SwiftUI

public struct ButtonWebsite: View {
    @Environment(\.locale) var locale
    var app: MyAppList.AppData
    public init(app: MyAppList.AppData) {
        self.app = app
    }
    public var body: some View {
        Button(action: {
            MyAppList.openURL(string: app.website!)
        }, label: {
            Text("website", bundle: .module)
                .environment(\.locale, locale)
        })
    }
}

#Preview {
    let app = MyAppList.AppData(
        name: "Example App",
        appId: "com.example.app",
        appstoreId: "123456789",
        platform: .macOS,
        website: "https://example.com"
    )

    ButtonWebsite(app: app)
        .padding()
}
