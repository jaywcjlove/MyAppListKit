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
        Button("website".localized(locale: locale)) {
            MyAppList.openURL(string: app.website!)
        }
    }
}

#Preview {
    ButtonWebsite(app: MyAppList.appMenuist)
        .padding()
}
