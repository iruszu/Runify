//
//  RunDetailSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-01-27.
//

import SwiftUI
import MapKit

struct RunDetailSheet: View {
    let run: Run
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var runTracker: RunTracker
    
    // Computed property that updates when run changes
    private var mapRegion: MKCoordinateRegion {
        MapRegionCalculator.calculateBoundingRegion(for: run)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Route")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Map(position: .constant(.region(mapRegion))) {
                            // Show the run route
                            if !run.locations.isEmpty {
                                let coordinates = run.locations.map { $0.clCoordinate }
                                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                                MapPolyline(polyline)
                                    .stroke(.blue, lineWidth: 4)
                            }
                            
                            // Start marker
                            if let startLocation = run.startLocation {
                                Annotation("Start", coordinate: startLocation.clCoordinate) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                            }
                            
                            // End marker (last location)
                            if let lastLocation = run.locations.last {
                                Annotation("End", coordinate: lastLocation.clCoordinate) {
                                    Image(systemName: "stop.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .mapStyle(runTracker.mapStyle)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)

                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            DetailRow(label: "Date", value: run.formattedDate)
                            DetailRow(label: "Distance", value: run.formattedDistance)
                            DetailRow(label: "Duration", value: run.formattedTime)
                            DetailRow(label: "Average Pace", value: run.formattedPace)
                            DetailRow(label: "Average Speed", value: run.formattedAverageSpeed)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(run.locationName)
            }


        }
    }
}

// MARK: - Supporting Views

struct StatisticsCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sampleRun = Run(
        locationName: "Morning Run",
        date: Date(),
        distance: 5000,
        duration: 1500,
        pace: 5.0,
        startLocation: Coordinate(latitude: 37.7749, longitude: -122.4194),
        locations: [
            Coordinate(latitude: 37.7749, longitude: -122.4194),
            Coordinate(latitude: 37.7849, longitude: -122.4094),
            Coordinate(latitude: 37.7949, longitude: -122.3994)
        ]
    )
    
    return RunDetailSheet(run: sampleRun)
}
