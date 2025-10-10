//
//  TabView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI

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
        
                .fullScreenCover(isPresented: $coordinator.showRun, content: {
                    RunView()
                        .environmentObject(runTracker)
                        .environmentObject(coordinator)
                })
                .transaction { transaction in
                    transaction.disablesAnimations = true // Disable animations for the transition
                }
                .fullScreenCover(isPresented: $coordinator.showCountdown, content: {
                    CountDownView()
                        .environmentObject(runTracker) // Pass the RunTracker to the countdown view
                        .environmentObject(coordinator)
                })
                .fullScreenCover(isPresented: $coordinator.showRunSummary, content: {
                    RunSummaryView()
                        .environmentObject(runTracker)
                        .environmentObject(coordinator)
                })
        .tabViewBottomAccessory {
            Button(action: {
                coordinator.showCountdown.toggle() // Use coordinator for navigation
            }, label: {
                Text("Start")
                Image(systemName: "figure.run")

            })
                
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
