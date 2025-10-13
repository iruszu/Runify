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
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var runTracker: RunTracker
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var selectedLocation: MKMapItem?
    @State private var isGoSelected: Bool = true
    @State private var showLocationDetail = false
    
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
                        selectedRoute = nil
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
                            
                            if isGoSelected && selectedRoute == nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isGoSelected && selectedRoute == nil ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
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
                                            showLocationDetail = true
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
        .sheet(isPresented: $showLocationDetail) {
            if let location = selectedLocation {
                LocationSheet(mapItem: location, routeDistance: 0)
                    .environmentObject(runTracker)
                    .environmentObject(coordinator)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            viewModel.setRunTracker(runTracker)
            viewModel.loadRecommendedRoutes()
        }
    }
       
    
    private func handleStartRun() {
        dismiss()
        
        // Start countdown immediately
        // TODO: Pass selected route to run tracker if a route is selected
        coordinator.navigateToCountdown()
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
        
        let itemLocation = CLLocation(
            latitude: mapItem.placemark.coordinate.latitude,
            longitude: mapItem.placemark.coordinate.longitude
        )
        let distanceInKm = userLocation.distance(from: itemLocation) / 1000
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
        .environmentObject(AppCoordinator())
        .environmentObject(RunTracker())
}
