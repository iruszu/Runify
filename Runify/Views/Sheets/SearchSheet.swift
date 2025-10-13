//
//  SearchSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

struct SearchSheet: View {
    @EnvironmentObject var runTracker: RunTracker
    @State private var searchText: String = ""
    @State private var filterByDistance: Bool = false
    @State private var routeDistance: Double = 5.0 // Default 5km
    
    // Search results
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false
    
    // Location detail sheet
    @State private var selectedLocation: MKMapItem?
    @State private var showLocationDetail = false
    
    // Placeholder data - will be replaced with actual data later
    @State private var recentLocations: [String] = []
    @State private var nearbyLocations: [String] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Search Results Section
                    if !searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.accentColor)
                                Text("Search Results")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if isSearching {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if searchResults.isEmpty && !isSearching {
                                Text("No results found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(searchResults, id: \.self) { item in
                                    SearchResultRow(
                                        mapItem: item,
                                        userLocation: runTracker.lastLocation?.coordinate
                                    ) {
                                        selectedLocation = item
                                        showLocationDetail = true
                                    }
                                }
                            }
                        }
                    }

                    // Recents Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.accentColor)
                            Text("Recents")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)
                        
                        if recentLocations.isEmpty {
                            Text("No recent searches")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(recentLocations, id: \.self) { location in
                                LocationRow(
                                    name: location,
                                    icon: "clock",
                                    distance: nil
                                )
                            }
                        }
                    }
                    
                    
                    // Near You Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.accentColor)
                            Text("Near You")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)
                        
                        if nearbyLocations.isEmpty {
                            Text("No nearby locations found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(nearbyLocations, id: \.self) { location in
                                LocationRow(
                                    name: location,
                                    icon: "mappin.circle",
                                    distance: "2.5 km" // Placeholder
                                )
                            }
                        }
                    }
                                    
                    
                    // Distance Filter Section
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $filterByDistance) {
                            HStack {
                                Image(systemName: "ruler")
                                    .foregroundColor(.accentColor)
                                Text("Filter by distance")
                                    .font(.headline)
                            }
                        }
                        .tint(.accentColor)
                        
                        if filterByDistance {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("0 km")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.1f", routeDistance)) km")
                                        .font(.headline)
                                        .foregroundColor(.accentColor)
                                    
                                    Spacer()
                                    
                                    Text("30 km")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(value: $routeDistance, in: 0...30, step: 0.5)
                                    .tint(.accentColor)
                                
                                Text("Choose how far you want your run to be")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                    
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .animation(.easeInOut(duration: 0.3), value: filterByDistance)
                    
                    Spacer(minLength: 40)

                }
                .padding(.vertical, 8)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search destinations")
            .onChange(of: searchText) { oldValue, newValue in
                if !newValue.isEmpty {
                    Task {
                        await performSearch(query: newValue)
                    }
                } else {
                    searchResults = []
                }
            }
            .sheet(isPresented: $showLocationDetail) {
                if let location = selectedLocation {
                    LocationSheet(mapItem: location, routeDistance: routeDistance)
                        .environmentObject(runTracker)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    // MARK: - Search Function
    
    private func performSearch(query: String) async {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Use user's current location region if available
        if let userLocation = runTracker.lastLocation {
            // Set search region to 100km radius (same city/region)
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 100000, // 100km radius
                longitudinalMeters: 100000
            )
            request.region = region
            
            // Prioritize results within this region
            request.regionPriority = .default
        }
        
        // Apply distance filter if enabled
        if filterByDistance {
            request.regionPriority = .required
        }
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            await MainActor.run {
                // Sort results by distance from user (closest first)
                if let userLocation = runTracker.lastLocation {
                    let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                    
                    searchResults = response.mapItems.sorted { item1, item2 in
                        let location1 = CLLocation(latitude: item1.placemark.coordinate.latitude, longitude: item1.placemark.coordinate.longitude)
                        let location2 = CLLocation(latitude: item2.placemark.coordinate.latitude, longitude: item2.placemark.coordinate.longitude)
                        
                        let distance1 = userCLLocation.distance(from: location1)
                        let distance2 = userCLLocation.distance(from: location2)
                        
                        return distance1 < distance2
                    }
                } else {
                    // If no user location, just use the default order
                    searchResults = response.mapItems
                }
                
                isSearching = false
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
            await MainActor.run {
                searchResults = []
                isSearching = false
            }
        }
    }
}

// MARK: - Search Result Row Component

struct SearchResultRow: View {
    let mapItem: MKMapItem
    let userLocation: CLLocationCoordinate2D?
    let action: () -> Void
    
    private var distance: String? {
        guard let userLocation = userLocation else { return nil }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let itemLocation = CLLocation(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: itemLocation)
        let distanceInKm = distanceInMeters / 1000
        
        return String(format: "%.1f km", distanceInKm)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mapItem.name ?? "Unknown Location")
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let address = mapItem.placemark.title {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if let distance = distance {
                        Text(distance)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

// MARK: - Location Row Component

struct LocationRow: View {
    let name: String
    let icon: String
    let distance: String?
    
    var body: some View {
        Button(action: {
            // Action will be implemented later
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let distance = distance {
                        Text(distance)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

#Preview {
    SearchSheet()
}
