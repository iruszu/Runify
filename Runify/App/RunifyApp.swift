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
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .environmentObject(healthKitManager)
        }
        .modelContainer(for: Run.self)
        
        
    }
}
