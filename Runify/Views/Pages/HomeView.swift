//
//  HomeView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                DateCard(date: Date())
                    .padding(20)
            

                if runs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No runs yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Complete your first run to see it here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {

                    // Horizontal scroll view of run summary cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 30) {
                            ForEach(runs, id: \.id) { run in
                                RunSummaryCard(run: run)
                                    .frame(width: 300) // Fixed width for consistent sizing
                                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.horizontal, (UIScreen.main.bounds.width - 300) / 2) // Center the first card
      
                    }
                    .scrollTargetBehavior(.viewAligned)
                }
                    }
                    .background(Color(.systemBackground))
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
        )
    ]
    
    // Insert sample runs into the container
    for run in sampleRuns {
        container.mainContext.insert(run)
    }
    
    return HomeView()
        .modelContainer(container)
}
