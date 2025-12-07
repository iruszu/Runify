//
//  AllRecommendationsSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

struct AllRecommendationsSheet: View {
    @Environment(RunTracker.self) private var runTracker
    @Environment(\.dismiss) var dismiss
    
    let userLocation: CLLocation?
    
    @State private var parks: [MKMapItem] = []
    @State private var beaches: [MKMapItem] = []
    @State private var nationalParks: [MKMapItem] = []
    @State private var campgrounds: [MKMapItem] = []
    @State private var waterfront: [MKMapItem] = []
    @State private var landmarks: [MKMapItem] = []
    @State private var universities: [MKMapItem] = []
    @State private var popularDestinations: [MKMapItem] = []
    @State private var isLoading = false
    
    @State private var selectedLocation: MKMapItem?
    @State private var showLocationDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.top, 40)
                    } else {
                        
                        // Parks Section
                        if !parks.isEmpty {
                            POISection(
                                title: "Parks",
                                icon: "tree.fill",
                                items: parks,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // Beaches Section
                        if !beaches.isEmpty {
                            POISection(
                                title: "Beaches",
                                icon: "beach.umbrella.fill",
                                items: beaches,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // National Parks Section
                        if !nationalParks.isEmpty {
                            POISection(
                                title: "National Parks",
                                icon: "mountain.2.fill",
                                items: nationalParks,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // Campgrounds Section
                        if !campgrounds.isEmpty {
                            POISection(
                                title: "Campgrounds",
                                icon: "tent.fill",
                                items: campgrounds,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // Waterfront Section
                        if !waterfront.isEmpty {
                            POISection(
                                title: "Waterfront & Marina",
                                icon: "water.waves",
                                items: waterfront,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // Landmarks Section
                        if !landmarks.isEmpty {
                            POISection(
                                title: "Landmarks & Museums",
                                icon: "building.columns.fill",
                                items: landmarks,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // Universities Section
                        if !universities.isEmpty {
                            POISection(
                                title: "Universities & Campuses",
                                icon: "graduationcap.fill",
                                items: universities,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        // Popular Destinations Section
                        if !popularDestinations.isEmpty {
                            POISection(
                                title: "Popular Destinations",
                                icon: "star.fill",
                                items: popularDestinations,
                                userLocation: userLocation?.coordinate
                            ) { item in
                                selectedLocation = item
                                showLocationDetail = true
                            }
                        }
                        
                        if parks.isEmpty && beaches.isEmpty && nationalParks.isEmpty && campgrounds.isEmpty && waterfront.isEmpty && landmarks.isEmpty && universities.isEmpty && popularDestinations.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "map")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                Text("No recommendations found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("All Recommendations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showLocationDetail) {
            if let location = selectedLocation {
                LocationSheet(mapItem: location, routeDistance: 0)
                    .environment(runTracker)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            loadAllRecommendations()
        }
    }
    
    private func loadAllRecommendations() {
        guard let userLocation = userLocation else { return }
        
        isLoading = true
        
        Task {
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 100000,
                longitudinalMeters: 100000
            )
            
            // Load all POI types in parallel using async let for better performance
            async let parksResult = loadPOIType(.park, region: region, userLocation: userLocation)
            async let beachesResult = loadPOIType(.beach, region: region, userLocation: userLocation)
            async let nationalParksResult = loadPOIType(.nationalPark, region: region, userLocation: userLocation)
            async let campgroundsResult = loadPOIType(.campground, region: region, userLocation: userLocation)
            async let waterfrontResult = loadMultiplePOITypes([.marina, .aquarium], region: region, userLocation: userLocation)
            async let landmarksResult = loadMultiplePOITypes([.museum, .library, .stadium, .zoo], region: region, userLocation: userLocation)
            async let universitiesResult = loadPOIType(.university, region: region, userLocation: userLocation)
            async let popularDestinationsResult = loadMultiplePOITypes([.restaurant, .cafe, .store, .movieTheater], region: region, userLocation: userLocation)
            
            // Wait for all tasks to complete and update state on main actor
            let (parksItems, beachesItems, nationalParksItems, campgroundsItems, waterfrontItems, landmarksItems, universitiesItems, popularDestinationsItems) = await (
                parksResult,
                beachesResult,
                nationalParksResult,
                campgroundsResult,
                waterfrontResult,
                landmarksResult,
                universitiesResult,
                popularDestinationsResult
            )
            
            await MainActor.run {
                self.parks = parksItems
                self.beaches = beachesItems
                self.nationalParks = nationalParksItems
                self.campgrounds = campgroundsItems
                self.waterfront = waterfrontItems
                self.landmarks = landmarksItems
                self.universities = universitiesItems
                self.popularDestinations = popularDestinationsItems
                self.isLoading = false
            }
        }
    }
    
    private func loadPOIType(_ category: MKPointOfInterestCategory, region: MKCoordinateRegion, userLocation: CLLocation) async -> [MKMapItem] {
        let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            // Move sorting to background thread (CPU-intensive distance calculations)
            let sorted = await Task.detached(priority: .userInitiated) {
                return response.mapItems.sorted { item1, item2 in
                    return userLocation.distance(from: item1.location) < userLocation.distance(from: item2.location)
                }
            }.value
            
            return sorted
        } catch {
            print("POI search error for \(category): \(error.localizedDescription)")
            return []
        }
    }
    
    private func loadMultiplePOITypes(_ categories: [MKPointOfInterestCategory], region: MKCoordinateRegion, userLocation: CLLocation) async -> [MKMapItem] {
        let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: categories)
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            // Move sorting to background thread (CPU-intensive distance calculations)
            let sorted = await Task.detached(priority: .userInitiated) {
                return response.mapItems.sorted { item1, item2 in
                    return userLocation.distance(from: item1.location) < userLocation.distance(from: item2.location)
                }
            }.value
            
            return sorted
        } catch {
            print("POI search error for multiple categories: \(error.localizedDescription)")
            return []
        }
    }
}

