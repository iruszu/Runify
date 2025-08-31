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
                .preferredColorScheme(.dark) // Force dark mode always
        }
        .modelContainer(for: Run.self)
        
    }
}
