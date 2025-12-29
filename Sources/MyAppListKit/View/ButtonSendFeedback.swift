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
        Button(action: {
            let emailURLString: String = app.sendFeedback(content: MyAppList.version, locale: locale)
            MyAppList.openURL(string: emailURLString)
        }, label: {
            Text("send_feedback", bundle: .module)
                .environment(\.locale, locale)
        })
    }
}

#Preview {
    ButtonSendFeedback(app: MyAppList.appMenuist)
        .padding()
}
