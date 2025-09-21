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
    var body: some Scene {
        WindowGroup {
            ContentView()
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
