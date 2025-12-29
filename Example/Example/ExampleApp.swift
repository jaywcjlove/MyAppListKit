//
//  ExampleApp.swift
//  Example
//
//  Created by 王楚江 on 2024/11/27.
//

import SwiftUI
import MyAppListKit

@main
struct ExampleApp: App {
    @Environment(\.locale) var locale
    var body: some Scene {
        WindowGroup {
            let locale: Locale = Locale(identifier: Locale.preferredLanguages.first ?? "en")
            ContentView()
                .environment(\.locale, .init(identifier: locale.identifier))
        }
        .commands {
            CommandMenus()
        }
    }
}

struct CommandMenus: Commands {
    var body: some Commands {
        MoreAppsCommandMenus()
        
    }
}
