//
//  TabView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var runTracker = RunTracker()
    @State private var showRunOptions = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
                    .environmentObject(runTracker)
            }
            Tab("Statistics", systemImage: "chart.line.uptrend.xyaxis") {
                Text("Placeholder")
            }
            Tab("Map", systemImage: "map", role: .search) {
                MapView()
                    .environmentObject(coordinator)
                    .environmentObject(runTracker)
            }
            Tab("Profile", systemImage: "person.circle") {
                ProfileView()
                    .environmentObject(runTracker)
            }
        }
        .fullScreenCover(isPresented: $coordinator.showRunningMap) {
            RunningMapView()
                .environmentObject(runTracker)
                .environmentObject(coordinator)
        }
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
                showRunOptions = true
            }, label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Start Run")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

            })
        }
        .sheet(isPresented: $showRunOptions) {
            RunOptionsSheet()
                .environmentObject(coordinator)
                .presentationBackground(.clear)
        }
        .onAppear {
            // Inject modelContext into RunTracker
            runTracker.setModelContext(modelContext)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Run.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Add sample runs to the container
    let sampleRuns = [
        Run(
            locationName: "Morning Run",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            distance: 5000, // 5km
            duration: 1500, // 25 minutes
            pace: 5.0,
            startLocation: Coordinate(latitude: 37.7749, longitude: -122.4194)
        ),
        Run(
            locationName: "Evening Jog",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            distance: 3200, // 3.2km
            duration: 1200, // 20 minutes
            pace: 6.25,
            startLocation: Coordinate(latitude: 37.7849, longitude: -122.4094)
        ),
        Run(
            locationName: "Weekend Long Run",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            distance: 10000, // 10km
            duration: 3600, // 60 minutes
            pace: 6.0,
            startLocation: Coordinate(latitude: 37.7649, longitude: -122.4294)
        ),
        Run(
            locationName: "Quick Sprint",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
            distance: 1000, // 1km
            duration: 300, // 5 minutes
            pace: 5.0,
            startLocation: Coordinate(latitude: 37.7549, longitude: -122.4394)
        ),
        Run(
            locationName: "Trail Run",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            distance: 7500, // 7.5km
            duration: 2700, // 45 minutes
            pace: 6.0,
            startLocation: Coordinate(latitude: 37.7449, longitude: -122.4494)
        ),
        Run(
            locationName: "Beach Run",
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
            distance: 6000, // 6km
            duration: 2400, // 40 minutes
            pace: 6.67,
            startLocation: Coordinate(latitude: 37.7349, longitude: -122.4594)
        ),
        Run(
            locationName: "City Exploration",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            distance: 8500, // 8.5km
            duration: 3000, // 50 minutes
            pace: 5.88,
            startLocation: Coordinate(latitude: 37.7249, longitude: -122.4694)
        )
    ]
    
    // Insert sample runs into the container
    for run in sampleRuns {
        container.mainContext.insert(run)
    }
    
    // Save the context to persist the data
    try? container.mainContext.save()
    
    if #available(iOS 26.0, *) {
        return MainTabView()
            .modelContainer(container)
            .environmentObject(AppCoordinator())
            .environmentObject(RunTracker())
    } else {
        // Fallback on earlier versions
        return MainTabView()
            .modelContainer(container)
            .environmentObject(AppCoordinator())
            .environmentObject(RunTracker())
    }
}
