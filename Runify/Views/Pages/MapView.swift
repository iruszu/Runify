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

    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
            Map(position: $runTracker.staticRegion) {
                UserAnnotation()

                }
                .mapStyle(runTracker.mapStyle)
                .ignoresSafeArea(edges: .bottom)

                
                Button {
                    coordinator.navigateToCountdown() // Use coordinator for navigation
                } label: {
                    Text("Start")
                        .bold()
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding(60)
                        .background(.blue)
                        .glassEffect() // Apply glass effect here, before clipping
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .padding(.bottom, 50)
                
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Standard") {
                            runTracker.mapStyle = .standard
                        }
                        Button("Imagery") {
                            runTracker.mapStyle = .imagery
                        }
                        Button("Hybrid") {
                            runTracker.mapStyle = .hybrid
                        }
                    } label: {
                        Image(systemName: "map")
                            .foregroundColor(.primary)
                    }
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
