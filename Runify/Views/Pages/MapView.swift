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
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
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

    // MARK: - Computed Properties
    
    private var selectedRunPolyline: some MapContent {
        Group {
            if showRouteOnMap, let selectedRun = selectedRun, !selectedRun.locations.isEmpty {
                let coordinates = selectedRun.locations.map { $0.clCoordinate }
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
                Map(position: $runTracker.staticRegion, selection: $selectedRun) {
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showMapSelection = true
                    }) {
                        Image(systemName: "map")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // filter markers by favourited
                        showFavouriteRunsOnly.toggle()
                        
                    }) {
                        Image(systemName: showFavouriteRunsOnly ? "heart.fill" : "heart")
                            .foregroundColor(showFavouriteRunsOnly ? .red : .white)
                    }
                    
                }
            }
            .sheet(isPresented: $showMapSelection) {
                MapSelectionSheet()
                    .environmentObject(runTracker)
            }
            .sheet(isPresented: Binding(
                get: { showRunDetailSheet && selectedRun != nil },
                set: { showRunDetailSheet = $0 }
            )) {
                if let selectedRun = selectedRun {
                    RunDetailSheet(run: selectedRun)
                        .environmentObject(runTracker)
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
        .environmentObject(RunTracker()) // Provide the RunTracker to the preview
        .environmentObject(AppCoordinator()) // Provide the AppCoordinator to the preview
}
