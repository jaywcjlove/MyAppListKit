//
//  ButtonSendFeedback.swift
//  MyAppListKit
//
//  Created by wong on 3/18/25.
//

import SwiftUI

public struct ButtonSendFeedback: View {
    @Environment(\.locale) var locale
    var app: MyAppList.AppData
    public init(app: MyAppList.AppData) {
        self.app = app
    }
    public var body: some View {
        Button("send_feedback".localized(locale: locale)) {
            let emailURLString: String = app.sendFeedback(content: MyAppList.version, locale: locale)
            MyAppList.openURL(string: emailURLString)
        }
    }
}
