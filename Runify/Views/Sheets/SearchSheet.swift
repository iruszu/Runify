//
//  SearchSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

struct SearchSheet: View {
    @Environment(RunTracker.self) private var runTracker
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = SearchViewModel()
    
    @State private var selectedLocation: MKMapItem?
    @State private var showLocationDetail = false
    @State private var showAllRecommendations = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Search Results Section
                    if !viewModel.searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.accentColor)
                                Text("Search Results")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if viewModel.isSearching {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                                Text("No results found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(viewModel.searchResults, id: \.self) { item in
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
                    if !viewModel.recentSearches.isEmpty && viewModel.searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.accentColor)
                                Text("Recents")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)
                            
                            ForEach(viewModel.recentSearches) { search in
                                RecentSearchRow(
                                    name: search.name,
                                    address: search.address
                                ) {
                                    // Convert RecentSearch back to MKMapItem for display
                                    let placemark = MKPlacemark(coordinate: search.coordinate)
                                    let mapItem = MKMapItem(placemark: placemark)
                                    mapItem.name = search.name
                                    selectedLocation = mapItem
                                    showLocationDetail = true
                                }
                            }
                        }
                    }
                    
                    // Near You Section
                    if !viewModel.nearbyLocations.isEmpty && viewModel.searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("Near You")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if viewModel.isLoadingNearby {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            ForEach(viewModel.nearbyLocations, id: \.self) { item in
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
                    
                    // Recommended Routes Section
                    if viewModel.searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "figure.hiking")
                                    .foregroundColor(.accentColor)
                                Text("Recommended Routes")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if viewModel.isLoadingRecommended {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else if !viewModel.recommendedRoutes.isEmpty {
                                    Button(action: {
                                        showAllRecommendations = true
                                    }) {
                                        Text("See More")
                                            .font(.subheadline)
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if viewModel.recommendedRoutes.isEmpty && !viewModel.isLoadingRecommended {
                                Text("No recommended routes found in your region")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(viewModel.recommendedRoutes.prefix(5), id: \.self) { item in
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
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 8)
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer, prompt: "Search destinations")
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                if !newValue.isEmpty {
                    Task {
                        await viewModel.performSearch(query: newValue)
                    }
                } else {
                    viewModel.searchResults = []
                }
            }
            .sheet(isPresented: $showLocationDetail) {
                if let location = selectedLocation {
                    LocationSheet(mapItem: location, routeDistance: viewModel.routeDistance)
                        .environment(runTracker)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .onDisappear {
                            if let location = selectedLocation {
                                viewModel.saveRecentSearch(location)
                            }
                        }
                }
            }
            .sheet(isPresented: $showAllRecommendations) {
                AllRecommendationsSheet(userLocation: runTracker.lastLocation)
                    .environment(runTracker)
            }
            .onAppear {
                // Set the runTracker reference in viewModel
                viewModel.setRunTracker(runTracker)
                viewModel.loadRecentSearches()
                viewModel.loadNearbyLocations()
                viewModel.loadRecommendedRoutes()
            }
        }
    }
}

#Preview {
    SearchSheet()
        .environment(RunTracker())
        .environment(AppCoordinator())
}
