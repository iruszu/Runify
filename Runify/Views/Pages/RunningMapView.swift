//
//  RunningMapView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-10.
//

import SwiftUI
import MapKit

struct RunningMapView: View {
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showRunSheet = true // Auto-show RunView sheet
    
    var body: some View {
        NavigationStack {
            ZStack {
            // Full-screen map with route tracking
            Map(position: $runTracker.region) {
                UserAnnotation()
                
                // Show current route
                if !runTracker.locations.isEmpty {
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
                            .font(.title)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .mapStyle(runTracker.mapStyle)
            .ignoresSafeArea()
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Standard") {
                        runTracker.mapStyle = .standard
                    }
                    Button("Imagery") {
                        runTracker.mapStyle = .imagery
                    }
                    Button("Hybrid") {
                        runTracker.mapStyle = .hybrid
                    }
                } label: {
                    Image(systemName: "map")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showRunSheet) {
            RunView()
                .environmentObject(runTracker)
                .environmentObject(coordinator)
                .presentationDetents([.fraction(0.3), .medium])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true) // Cannot dismiss the sheet
                .presentationBackgroundInteraction(.enabled) // Make background transparent/not dimmed
        }
        .onAppear {
            // Start tracking when this view appears (only if not already running)
            if !runTracker.isRunning {
                runTracker.startRun()
            }
        }
        }
    }
}

#Preview {
    RunningMapView()
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}
