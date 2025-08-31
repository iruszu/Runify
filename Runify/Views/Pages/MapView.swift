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
    
            .fullScreenCover(isPresented: $coordinator.showRun, content: {
                RunView()
                    .environmentObject(runTracker)
                    .environmentObject(coordinator)
            })
            .transaction { transaction in
                transaction.disablesAnimations = true // Disable animations for the transition
            }
            .fullScreenCover(isPresented: $coordinator.showCountdown, content: {
                CountDownView()
                    .environmentObject(runTracker) // Pass the RunTracker to the countdown view
                    .environmentObject(coordinator)
            })
            .fullScreenCover(isPresented: $coordinator.showRunSummary, content: {
                RunSummaryView()
                    .environmentObject(runTracker)
                    .environmentObject(coordinator)
            })
            
           
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
