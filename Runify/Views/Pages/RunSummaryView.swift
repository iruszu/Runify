//
//  RunSummaryView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI

struct RunSummaryView: View {
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Run Complete")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .background(Color(.systemBackground))
                .frame(maxWidth: .infinity, alignment: .leading)
                
            
            VStack(spacing: 20) {
                SummaryCard(
                    title: "Distance",
                    value: String(format: "%.2f m", runTracker.distance),
                    icon: "figure.run"
                )
                
                SummaryCard(
                    title: "Time",
                    value: formatTime(seconds: runTracker.elapsedTime),
                    icon: "clock"
                )
                
                SummaryCard(
                    title: "Pace",
                    value: String(format: "%.2f min/km", runTracker.pace),
                    icon: "speedometer"
                )
                
                SummaryCard(
                    title: "Avg Speed",
                    value: String(format: "%.1f km/h", runTracker.distance > 0 ? (runTracker.distance / 1000.0) / (runTracker.elapsedTime / 3600.0) : 0),
                    icon: "gauge"
                )
                
                // Map showing run location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let startLocation = runTracker.startLocation {
                        RunLocationMapView(run: Run(
                            locationName: "Current Run",
                            date: Date(),
                            distance: runTracker.distance,
                            duration: runTracker.elapsedTime,
                            pace: runTracker.pace,
                            startLocation: Coordinate(startLocation.coordinate)
                        ))
                    } else {
                        Text("No location data available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            
            Spacer()
            
            Button {
                coordinator.finishRunSummary()
            } label: {
                Text("Done")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 20)
   
            }
            .buttonStyle(.borderedProminent)
            .glassEffect()
        }
        .padding()
        .navigationBarHidden(true)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
    
    private func formatTime(seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)

                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RunSummaryView()
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}
