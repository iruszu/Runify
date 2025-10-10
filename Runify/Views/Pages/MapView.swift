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

    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                Map(position: $runTracker.region) {
                    UserAnnotation()

                }
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

            
           
        }
        .padding(.top, -150)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)

        
    }
       
    
}
    

#Preview {
    MapView()
        .environmentObject(RunTracker()) // Provide the RunTracker to the preview
        .environmentObject(AppCoordinator()) // Provide the AppCoordinator to the preview
}
