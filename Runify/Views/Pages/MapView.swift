//
//  HomeView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(RunTracker.self) private var runTracker
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @Query private var runs: [Run]
    private var filteredRuns: [Run] {
        if showFavouriteRunsOnly {
            return runs.filter { $0.isFavorited }
        } else {
            return runs
        }
    }
    
    @State private var hasInitialized = false
    @State private var showMapSelection = false
    @State private var selectedRun: Run?
    @State private var showRunDetailSheet = false
    @State private var showRouteOnMap = false
    @State private var showFavouriteRunsOnly: Bool = false
    @State private var showRunOptions = false
    @State private var showSearchSheet = false

    // MARK: - Computed Properties
    
    private var selectedRunPolyline: some MapContent {
        Group {
            if showRouteOnMap, let selectedRun = selectedRun, !selectedRun.locations.isEmpty {
                // Sort by sequence index to ensure correct order
                let sortedLocations = selectedRun.locations.sorted { $0.sequenceIndex < $1.sequenceIndex }
                let coordinates = sortedLocations.map { $0.clCoordinate }
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                MapPolyline(polyline)
                    .stroke(.orange, lineWidth: 4)
            }
        }
    }

    
    // MARK: - Methods
    
    private func handleRunSelection(_ run: Run) {

            selectedRun = run
            showRouteOnMap = true
            showRunDetailSheet = true
        
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                
                Map(position: Bindable(runTracker).staticRegion, selection: $selectedRun) {
                    UserAnnotation()
                    selectedRunPolyline
                    
                    ForEach(filteredRuns) { run in
                        if let startLocation = run.startLocation {
                            Marker(
                                run.locationName,
                                systemImage: "figure.run",
                                coordinate: startLocation.clCoordinate
                            )
                            .tag(run)
                            .tint(run.isFavorited ? .red : .blue)

                        }
                    }
                }
                .onChange(of: selectedRun) { oldValue, newValue in
                    if let run = newValue {
                        handleRunSelection(run)
                    }
                }
                .mapStyle(runTracker.mapStyle)
                .ignoresSafeArea(edges: .bottom)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapPitchToggle()
                }
                
                // Start Run Button
                VStack {
                    Spacer()
                    StartRunButton {
                        showRunOptions = true
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // filter markers by favourited
                        showFavouriteRunsOnly.toggle()
                        
                    }) {
                        Image(systemName: showFavouriteRunsOnly ? "heart.fill" : "heart")
                            .foregroundColor(showFavouriteRunsOnly ? .red : .white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearchSheet = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
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
                    .environment(runTracker)
            }
            .sheet(isPresented: $showRunOptions) {
                RunOptionsSheet()
                    .environment(coordinator)
                    .presentationBackground(.clear)
            }
            .sheet(isPresented: $showSearchSheet) {
                SearchSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .environment(runTracker)
                    .environment(coordinator)
            }
            .sheet(isPresented: Binding(
                get: { showRunDetailSheet && selectedRun != nil },
                set: { showRunDetailSheet = $0 }
            )) {
                if let selectedRun = selectedRun {
                    RunDetailSheet(run: selectedRun)
                        .environment(runTracker)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackgroundInteraction(.enabled)

                }
            }
            .onChange(of: showRunDetailSheet) { oldValue, newValue in
                if !newValue {
                    // Clear the route and selection when sheet is dismissed
                    showRouteOnMap = false
                    selectedRun = nil
                }
            }

            
           
        }
        .padding(.top, -50)
        .onAppear {
            // Center on user's current location when view first appears
            if !hasInitialized, let lastLocation = runTracker.lastLocation {
                runTracker.staticRegion = .region(
                    MKCoordinateRegion(
                        center: lastLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
                hasInitialized = true
            }
        }
  

        
    }
       
    
}
    

#Preview {
    MapView()
        .environment(RunTracker()) // Provide the RunTracker to the preview
        .environment(AppCoordinator()) // Provide the AppCoordinator to the preview
}
