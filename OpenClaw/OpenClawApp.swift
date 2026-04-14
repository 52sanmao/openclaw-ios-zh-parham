//
//  OpenClawApp.swift
//  OpenClaw
//
//  Created by Parham on 27/03/2026.
//

import SwiftUI

@main
struct OpenClawApp: App {
    init() {
        ChineseLocalization.install()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
