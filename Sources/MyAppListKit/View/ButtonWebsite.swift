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
    ButtonWebsite(app: MyAppList.appMenuist)
        .padding()
}
