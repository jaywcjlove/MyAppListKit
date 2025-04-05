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
        Button("rate_app".localized(locale: locale)) {
            app.openWriteReviewURL()
        }
    }
}
