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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Run.self)
        
        
    }
}
