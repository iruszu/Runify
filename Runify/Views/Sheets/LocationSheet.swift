//
//  LocationSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

struct LocationSheet: View {
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    let mapItem: MKMapItem
    let routeDistance: Double
    
    @State private var mapPosition: MapCameraPosition
    @State private var routeInfo: RouteInfo?
    @State private var isCalculatingRoute = false
    
    init(mapItem: MKMapItem, routeDistance: Double) {
        self.mapItem = mapItem
        self.routeDistance = routeDistance
        
        // Initialize map position centered on the location
        let region = MKCoordinateRegion(
            center: mapItem.location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        _mapPosition = State(initialValue: .region(region))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Map Preview
                    Map(position: $mapPosition) {
                        // Show route polyline if available
                        if let routeInfo = routeInfo {
                            MapPolyline(routeInfo.polyline)
                                .stroke(.blue, lineWidth: 4)
                        }
                        
                        // Destination marker
                        Marker(item: mapItem)
                        
                        // Show user location if available
                        if let userLocation = runTracker.lastLocation {
                            Annotation("You", coordinate: userLocation.coordinate) {
                                ZStack {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 20, height: 20)
                                    Circle()
                                        .stroke(.white, lineWidth: 3)
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Location Details
                    VStack(alignment: .leading, spacing: 16) {
                        // Name
                        Text(mapItem.name ?? "Unknown Location")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Address
                        if let address = formatAddress() {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle")
                                    .foregroundColor(.accentColor)
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Distance from user
                        if let distance = calculateDistance() {
                            HStack(spacing: 8) {
                                Image(systemName: "location")
                                    .foregroundColor(.accentColor)
                                Text("\(String(format: "%.1f", distance)) km from you")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Phone number
                        if let phoneNumber = mapItem.phoneNumber {
                            HStack(spacing: 8) {
                                Image(systemName: "phone")
                                    .foregroundColor(.accentColor)
                                Text(phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // URL
                        if let url = mapItem.url {
                            Link(destination: url) {
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                        .foregroundColor(.accentColor)
                                    Text("Website")
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        
                        
                        // Route Information
                        if isCalculatingRoute {
                            HStack {
                                ProgressView()
                                Text("Calculating route...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else if let routeInfo = routeInfo {
                            VStack(alignment: .center, spacing: 12) {
                                Text("Route Information")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 20) {
                                    Spacer()
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Distance")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f km", routeInfo.distance / 1000))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Est. Time")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatTime(routeInfo.expectedTravelTime))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Distance warnings with color coding
                                if let warningInfo = getDistanceWarning(routeInfo.distance / 1000) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(warningInfo.color)
                                        Text(warningInfo.message)
                                            .font(.caption)
                                            .foregroundColor(warningInfo.color)
                                    }
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                startRunToLocation()
                            }) {
                                HStack {
                                    Image(systemName: "figure.run")
                                    Text("Run")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(routeInfo != nil ? Color.accentColor : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(routeInfo == nil)
                            
                            Button(action: {
                                openInMaps()
                            }) {
                                HStack {
                                    Image(systemName: "map")
                                    Text("Open in Maps")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDragIndicator(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                       dismiss()
                    }
                }
            }
        }
        .onAppear {
            calculateRoute()
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatAddress() -> String? {
        return mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true)
    }
    
    private func calculateDistance() -> Double? {
        guard let userLocation = runTracker.lastLocation else { return nil }
        
        let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: mapItem.location)
        return distanceInMeters / 1000 // Convert to km
    }
    
    private func calculateRoute() {
        guard let userLocation = runTracker.lastLocation else { return }
        
        isCalculatingRoute = true
        
        let request = MKDirections.Request()
        request.source = MKMapItem(location: userLocation, address: nil)
        request.destination = mapItem
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        Task {
            do {
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    await MainActor.run {
                        routeInfo = RouteInfo(
                            distance: route.distance,
                            expectedTravelTime: route.expectedTravelTime,
                            polyline: route.polyline
                        )
                        
                        // Adjust map to show the entire route
                        let rect = route.polyline.boundingMapRect
                        let region = MKCoordinateRegion(rect)
                        
                        // Add some padding to the region
                        let paddedRegion = MKCoordinateRegion(
                            center: region.center,
                            span: MKCoordinateSpan(
                                latitudeDelta: region.span.latitudeDelta * 1.3,
                                longitudeDelta: region.span.longitudeDelta * 1.3
                            )
                        )
                        
                        mapPosition = .region(paddedRegion)
                        isCalculatingRoute = false
                    }
                }
            } catch {
                print("Route calculation error: \(error.localizedDescription)")
                await MainActor.run {
                    isCalculatingRoute = false
                }
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
    
    private func openInMaps() {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
    
    private func getDistanceWarning(_ distanceInKm: Double) -> (message: String, color: Color)? {
        switch distanceInKm {
        case 50...:
            return ("Very long distance - consider a shorter route", .red)
        case 40..<50:
            return ("This is an ultra-marathon distance", .red)
        case 20..<40:
            return ("Long distance run", .orange)
        case 10..<20:
            return ("Moderate distance", .yellow)
        default:
            return nil // No warning for under 10km
        }
    }
    
    private func startRunToLocation() {
        guard let routeInfo = routeInfo else { return }
        
        // Set planned route in coordinator
        coordinator.setPlannedRoute(
            destinationName: mapItem.name ?? "Unknown Location",
            coordinate: mapItem.location.coordinate,
            polyline: routeInfo.polyline
        )
        
        // Dismiss this sheet
        dismiss()
        
        // Start the countdown
        coordinator.navigateToCountdown()
    }
}

// MARK: - Route Info Model

struct RouteInfo {
    let distance: Double // in meters
    let expectedTravelTime: TimeInterval // in seconds
    let polyline: MKPolyline // Route polyline for map display
}

#Preview {
    let sampleLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
    let sampleMapItem = MKMapItem(location: sampleLocation, address: nil)
    sampleMapItem.name = "San Francisco"
    
    return LocationSheet(mapItem: sampleMapItem, routeDistance: 5.0)
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}

