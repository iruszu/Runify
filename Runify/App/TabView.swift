//
//  TabView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI

@available(iOS 26.0, *)
struct MainTabView: View {
    @State var selectedTab = 0
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var runTracker = RunTracker()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
                    .environmentObject(runTracker)
            }
            Tab("Map", systemImage: "map", role: .search) {
                MapView()
                    .environmentObject(coordinator)
                    .environmentObject(runTracker)
            }

            
            
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .onAppear {
            // Inject modelContext into RunTracker
            runTracker.setModelContext(modelContext)
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        MainTabView()
            .environmentObject(AppCoordinator())
            .environmentObject(RunTracker())
    } else {
        // Fallback on earlier versions
    }
}
