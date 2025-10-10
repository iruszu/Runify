//
//  RunifyApp.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import SwiftData

@main
struct RunifyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()

        }
        .modelContainer(for: Run.self)
        
    }
}
