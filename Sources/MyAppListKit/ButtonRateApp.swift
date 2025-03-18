//
//  RateApp.swift
//  MyAppListKit
//
//  Created by wong on 3/18/25.
//

import SwiftUI

struct ButtonRateApp: View {
    @Environment(\.locale) var locale
    var body: some View {
        Button("rate_app".localized(locale: locale)) {
            MyAppList.appIconed.openURL()
        }
    }
}
