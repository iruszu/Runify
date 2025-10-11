//
//  HomeView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var hasInitialized = false
    @State private var showMapSelection = false

    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
            Map(position: $runTracker.staticRegion) {
                UserAnnotation()

                }
                .mapStyle(runTracker.mapStyle)
                .ignoresSafeArea(edges: .bottom)

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
            }
            .sheet(isPresented: $showMapSelection) {
                MapSelectionSheet()
                    .environmentObject(runTracker)
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
