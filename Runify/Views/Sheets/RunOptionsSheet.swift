//
//  RunOptionsSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-10.
//

import SwiftUI
import MapKit

struct RunOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(RunTracker.self) private var runTracker
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var viewModel = SearchViewModel()
    
    @State private var selectedLocation: MKMapItem?
    @State private var isGoSelected: Bool = true
    @State private var showHealthKitPermission = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle area
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    Text("Ready to run?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                    
                    // Go option
                    Button(action: {
                        isGoSelected = true
                        selectedLocation = nil // Clear selected location
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "figure.run")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Go")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Start running immediately")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if isGoSelected && selectedLocation == nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isGoSelected && selectedLocation == nil ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Recommended routes section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recommended Routes")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if viewModel.isLoadingRecommended {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.leading, 8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.recommendedRoutes.isEmpty && !viewModel.isLoadingRecommended {
                            Text("No routes found nearby")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.recommendedRoutes.prefix(10), id: \.self) { mapItem in
                                        RouteCard(
                                            mapItem: mapItem,
                                            userLocation: runTracker.lastLocation,
                                            isSelected: selectedLocation == mapItem
                                        ) {
                                            selectedLocation = mapItem
                                            isGoSelected = false
                                        }
                                    }
                                }
                                .padding(.leading, 20)
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // Start button
                    StartRunButton {
                        handleStartRun()
                    }
       
                    .padding(.top, 8)
                }
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showHealthKitPermission) {
            HealthKitPermissionSheet {
                proceedWithRun()
            }
            .environment(healthKitManager)
            .presentationDetents([.fraction(0.75)])
        }
        .onAppear {
            viewModel.setRunTracker(runTracker)
            viewModel.loadRecommendedRoutes()
        }
    }
       
    
    private func handleStartRun() {
        // Check if HealthKit authorization has been requested
        if !healthKitManager.authorizationRequested {
            // Show HealthKit permission sheet first
            showHealthKitPermission = true
        } else {
            // Proceed with starting the run
            proceedWithRun()
        }
    }
    
    private func proceedWithRun() {
        // If a route is selected, calculate the route first
        if let selectedLocation = selectedLocation {
            calculateRouteAndStart(to: selectedLocation)
        } else {
            // Just start a regular run
            dismiss()
            coordinator.navigateToCountdown()
        }
    }
    
    private func calculateRouteAndStart(to mapItem: MKMapItem) {
        // Start the run immediately - don't wait for location
        // Location will be available when the run actually starts
        dismiss()
        coordinator.navigateToCountdown()
        
        // Set planned destination immediately (location-independent)
        // The polyline will be calculated in the background task below
        coordinator.setPlannedRoute(
            destinationName: mapItem.name ?? "Unknown Location",
            coordinate: mapItem.location.coordinate,
            polyline: nil // Will be calculated when location is available
        )
        
        // Calculate route in background (non-blocking) - don't delay UI
        Task {
            // Wait briefly for location if not immediately available
            var userLocation = runTracker.lastLocation
            if userLocation == nil {
                // Wait up to 2 seconds for location to become available
                for _ in 0..<20 {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    userLocation = runTracker.lastLocation
                    if userLocation != nil { break }
                }
            }
            
            guard let userLocation = userLocation else {
                // If no location, run will start without planned route
                // Location will be tracked once available
                return
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(location: userLocation, address: nil)
            request.destination = mapItem
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            
            do {
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    await MainActor.run {
                        // Update planned route with calculated polyline
                        coordinator.setPlannedRoute(
                            destinationName: mapItem.name ?? "Unknown Location",
                            coordinate: mapItem.location.coordinate,
                            polyline: route.polyline
                        )
                    }
                }
            } catch {
                print("Route calculation error: \(error.localizedDescription)")
                // Route calculation failed, but run already started
                // Run will continue without planned route
            }
        }
    }
}

// Route card component
struct RouteCard: View {
    let mapItem: MKMapItem
    let userLocation: CLLocation?
    let isSelected: Bool
    let onTap: () -> Void
    
    private var distance: String {
        guard let userLocation = userLocation else { return "-- km" }
        
        let distanceInKm = userLocation.distance(from: mapItem.location) / 1000
        return String(format: "%.1f km", distanceInKm)
    }
    
    private var category: String {
        if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .park: return "Park"
            case .beach: return "Beach"
            case .nationalPark: return "National Park"
            case .campground: return "Campground"
            case .marina: return "Waterfront"
            case .museum: return "Landmark"
            case .library: return "Landmark"
            case .stadium: return "Sports"
            case .university: return "Campus"
            case .zoo: return "Zoo"
            case .aquarium: return "Aquarium"
            default: return "Location"
            }
        }
        return "Location"
    }
    
    private var categoryColor: Color {
        if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .park, .nationalPark, .campground: return .green
            case .beach, .marina, .aquarium: return .blue
            case .museum, .library, .stadium, .university: return .orange
            default: return .gray
            }
        }
        return .gray
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Route name
                Text(mapItem.name ?? "Unknown Location")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Distance
                HStack(spacing: 12) {
                    Label(distance, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Category badge
                HStack {
                    Text(category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                }
            }
            .padding(12)
            .frame(width: 160, height: 120)
            .glassEffect(.regular.tint(isSelected ? .accentColor.opacity(0.2) : .black.opacity(0.1)), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RunOptionsSheet()
        .environment(AppCoordinator())
        .environment(RunTracker())
        .environment(HealthKitManager())
}
