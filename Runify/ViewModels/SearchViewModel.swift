//
//  SearchViewModel.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

@MainActor
class SearchViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var searchText: String = ""
    @Published var filterByDistance: Bool = false
    @Published var routeDistance: Double = 5.0
    
    // Search results
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching: Bool = false
    
    // Recent searches
    @Published var recentSearches: [RecentSearch] = []
    
    // Nearby locations
    @Published var nearbyLocations: [MKMapItem] = []
    @Published var isLoadingNearby: Bool = false
    
    // Recommended routes
    @Published var recommendedRoutes: [MKMapItem] = []
    @Published var isLoadingRecommended: Bool = false
    
    // Distance-filtered routes
    @Published var distanceFilteredRoutes: [MKMapItem] = []
    @Published var isLoadingDistanceFiltered: Bool = false
    
    // MARK: - Private Properties
    
    @AppStorage("recentSearches") private var recentSearchesData: String = "[]"
    private var runTracker: RunTracker?
    
    // MARK: - Initialization
    
    init() {
        // RunTracker will be set after initialization
    }
    
    func setRunTracker(_ tracker: RunTracker) {
        self.runTracker = tracker
    }
    
    // MARK: - Search Function
    
    func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Use user's current location region if available
        if let userLocation = runTracker?.lastLocation {
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
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            // Filter and sort results by distance from user
            if let userLocation = runTracker?.lastLocation {
                let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                
                // Filter out locations over 1000km away
                let filteredItems = response.mapItems.filter { item in
                    let distanceInKm = userCLLocation.distance(from: item.location) / 1000
                    return distanceInKm <= 1000
                }
                
                // Sort by distance (closest first)
                searchResults = filteredItems.sorted { item1, item2 in
                    let distance1 = userCLLocation.distance(from: item1.location)
                    let distance2 = userCLLocation.distance(from: item2.location)
                    
                    return distance1 < distance2
                }
            } else {
                // If no user location, just use the default order
                searchResults = response.mapItems
            }
            
            isSearching = false
        } catch {
            print("Search error: \(error.localizedDescription)")
            searchResults = []
            isSearching = false
        }
    }
    
    // MARK: - Recent Searches Functions
    
    func loadRecentSearches() {
        guard let data = recentSearchesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([RecentSearch].self, from: data) else {
            recentSearches = []
            return
        }
        recentSearches = decoded
    }
    
    func saveRecentSearch(_ mapItem: MKMapItem) {
        let addressString = mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) ?? ""
        
        let search = RecentSearch(
            name: mapItem.name ?? "Unknown Location",
            address: addressString,
            coordinate: mapItem.location.coordinate
        )
        
        // Remove duplicates (same name)
        recentSearches.removeAll { $0.name == search.name }
        
        // Add to beginning
        recentSearches.insert(search, at: 0)
        
        // Keep only 3 most recent
        if recentSearches.count > 3 {
            recentSearches = Array(recentSearches.prefix(3))
        }
        
        // Save to AppStorage
        if let encoded = try? JSONEncoder().encode(recentSearches),
           let jsonString = String(data: encoded, encoding: .utf8) {
            recentSearchesData = jsonString
        }
    }
    
    // MARK: - Nearby Locations Function
    
    func loadNearbyLocations() {
        guard let userLocation = runTracker?.lastLocation else { return }
        
        isLoadingNearby = true
        
        Task {
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 20000, // 20km radius
                longitudinalMeters: 20000
            )
            
            let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
            // Filter for running-friendly locations
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [
                .park,
                .beach,
                .nationalPark,
                .campground,
                .fitnessCenter,
                .stadium
            ])
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                
                // Filter to 10-20km range and sort by distance
                let filteredItems = response.mapItems.filter { item in
                    let distanceInKm = userCLLocation.distance(from: item.location) / 1000
                    return distanceInKm >= 10 && distanceInKm <= 20
                }.sorted { item1, item2 in
                    return userCLLocation.distance(from: item1.location) < userCLLocation.distance(from: item2.location)
                }
                
                nearbyLocations = Array(filteredItems.prefix(5)) // Show top 5
                isLoadingNearby = false
            } catch {
                print("Nearby search error: \(error.localizedDescription)")
                nearbyLocations = []
                isLoadingNearby = false
            }
        }
    }
    
    // MARK: - Recommended Routes Function
    
    func loadRecommendedRoutes() {
        guard let userLocation = runTracker?.lastLocation else { return }
        
        isLoadingRecommended = true
        
        Task {
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 100000, // 100km radius (same region)
                longitudinalMeters: 100000
            )
            
            let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
            // Filter for nature/outdoor running locations and popular destinations
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [
                .park,
                .beach,
                .nationalPark,
                .campground,
                .marina,           // Waterfront running
                .museum,           // Cultural landmarks
                .library,          // Community landmarks
                .stadium,          // Sports venues
                .university,       // Campus running
                .zoo,              // Scenic paths
                .aquarium,         // Waterfront areas
                .movieTheater,     // Entertainment districts
                .restaurant,       // Popular downtown areas
                .cafe,             // Popular neighborhoods
                .store             // Shopping districts
            ])
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                
                // Sort by distance and take top results
                let sortedItems = response.mapItems.sorted { item1, item2 in
                    return userCLLocation.distance(from: item1.location) < userCLLocation.distance(from: item2.location)
                }
                
                recommendedRoutes = Array(sortedItems.prefix(20))
                isLoadingRecommended = false
            } catch {
                print("Recommended routes search error: \(error.localizedDescription)")
                recommendedRoutes = []
                isLoadingRecommended = false
            }
        }
    }
    
    // MARK: - Distance-Filtered Routes Function
    
    func loadDistanceFilteredRoutes() {
        guard let userLocation = runTracker?.lastLocation else { return }
        
        isLoadingDistanceFiltered = true
        
        Task {
            // Search within the filter range (with buffer)
            let searchRadius = routeDistance * 1000 * 1.5 // 50% buffer to ensure results
            
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: searchRadius,
                longitudinalMeters: searchRadius
            )
            
            let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
            // Filter for nature/outdoor running locations and popular destinations
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [
                .park,
                .beach,
                .nationalPark,
                .campground,
                .marina,
                .museum,
                .library,
                .stadium,
                .university,
                .zoo,
                .aquarium,
                .movieTheater,
                .restaurant,
                .cafe,
                .store
            ])
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                
                // Filter to show results within ±30% of target distance
                let minDistance = routeDistance * 0.7
                let maxDistance = routeDistance * 1.3
                
                let filteredItems = response.mapItems.filter { item in
                    let distanceInKm = userCLLocation.distance(from: item.location) / 1000
                    return distanceInKm >= minDistance && distanceInKm <= maxDistance
                }.sorted { item1, item2 in
                    return userCLLocation.distance(from: item1.location) < userCLLocation.distance(from: item2.location)
                }
                
                distanceFilteredRoutes = filteredItems
                isLoadingDistanceFiltered = false
            } catch {
                print("Distance-filtered routes search error: \(error.localizedDescription)")
                distanceFilteredRoutes = []
                isLoadingDistanceFiltered = false
            }
        }
    }
}

