//
//  MapSnapshotService.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import Foundation
import SwiftUI
import MapKit

struct RunLocationMapView: View {
    let run: Run
    
    var body: some View {
        if let startLocation = run.startLocation {
            Map(position: .constant(.region(MKCoordinateRegion(
                center: startLocation.clCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))) {
                Marker("Start", coordinate: startLocation.clCoordinate)
                    .tint(.green)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        } else {
            // Fallback when no location data
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "location.slash")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No location data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
}

#Preview {
    let sampleRun = Run(
        locationName: "Sample Run",
        date: Date(),
        distance: 1000,
        duration: 300,
        pace: 5.0,
        startLocation: Coordinate(latitude: 49.2593, longitude: -123.247)
    )
    
    RunLocationMapView(run: sampleRun)
        .padding()
}
