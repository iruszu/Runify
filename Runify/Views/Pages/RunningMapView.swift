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
    @State private var showMapSelection = false
    @State private var mapSelection: MapSelection<Int>?
    @State private var initialMapPosition: MapCameraPosition?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen map with route tracking
            Map(position: Binding(
                get: { initialMapPosition ?? .automatic },
                set: { initialMapPosition = $0 }
            ), selection: $mapSelection) {
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
            .ignoresSafeArea(edges: .bottom)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapPitchToggle()
            }
            
            // Time display at the top
            VStack {
                FlipClockView(time: runTracker.elapsedTime)
                    .padding(.top, -30)
            
                
                Spacer()
            }

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showMapSelection = true
                }) {
                    Image(systemName: "map")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showMapSelection) {
            MapSelectionSheet()
                .environmentObject(runTracker)
        }
        .sheet(isPresented: $showRunSheet) {
            RunView()
                .environmentObject(runTracker)
                .environmentObject(coordinator)
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true) // Cannot dismiss the sheet
                .presentationBackgroundInteraction(.enabled) // Make background transparent/not dimmed
        }
        .onAppear {
            // Start tracking when this view appears (only if not already running)
            if !runTracker.isRunning {
                runTracker.startRun()
            }
            
            // Set initial map position to user's current location (only once)
            if initialMapPosition == nil {
                initialMapPosition = runTracker.region
            }
        }
        }
    }
    
    // Helper function to format time
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

// MARK: - Flip Clock Component
struct FlipClockView: View {
    let time: Double
    @State private var previousTime: Double = 0
    
    var body: some View {
        HStack(spacing: 8) {
            // Hours
            FlipDigitView(
                value: hours,
                previousValue: previousHours,
                label: "HOURS"
            )
            

            // Minutes
            FlipDigitView(
                value: minutes,
                previousValue: previousMinutes,
                label: "MINUTES"
            )
            
            
            // Seconds
            FlipDigitView(
                value: seconds,
                previousValue: previousSeconds,
                label: "SECONDS"
            )
        }
        .onAppear {
            previousTime = time
        }
        .onChange(of: time) { _, newTime in
            withAnimation(.easeInOut(duration: 0.3)) {
                previousTime = time
            }
        }
    }
    
    private var hours: Int {
        Int(time) / 3600
    }
    
    private var minutes: Int {
        Int(time) % 3600 / 60
    }
    
    private var seconds: Int {
        Int(time) % 60
    }
    
    private var previousHours: Int {
        Int(previousTime) / 3600
    }
    
    private var previousMinutes: Int {
        Int(previousTime) % 3600 / 60
    }
    
    private var previousSeconds: Int {
        Int(previousTime) % 60
    }
}

struct FlipDigitView: View {
    let value: Int
    let previousValue: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.4))
                    .frame(width: 60, height: 80)
                    .glassEffect(.regular.tint(.black.opacity(0.1)), in: RoundedRectangle(cornerRadius: 12))
                
                // Current value - no animation, just updates
                Text(String(format: "%02d", value))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            // Label
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .shadow(radius: 3)
                .textCase(.uppercase)

        }
    }
}

#Preview {
    RunningMapView()
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}
