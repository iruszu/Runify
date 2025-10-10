//
//  RunSummaryView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import MapKit

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
                
                // Map showing complete run route
                VStack(alignment: .leading, spacing: 8) {
                    Text("Route")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !runTracker.locations.isEmpty {
                        Map {
                            // Show the complete route
                            if runTracker.locations.count > 1 {
                                let coordinates = runTracker.locations.map { $0.coordinate }
                                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                                MapPolyline(polyline)
                                    .stroke(.orange, lineWidth: 4)
                            }
                            
                            // Show start marker
                            if let startLocation = runTracker.startLocation {
                                Annotation("Start", coordinate: startLocation.coordinate) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                            }
                            
                            // Show end marker
                            if let lastLocation = runTracker.lastLocation {
                                Annotation("Finish", coordinate: lastLocation.coordinate) {
                                    Image(systemName: "flag.checkered")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .mapStyle(runTracker.mapStyle)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    } else {
                        Text("No route data available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .frame(height: 200)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
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
