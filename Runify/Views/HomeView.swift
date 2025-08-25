//
//  HomeView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var runTracker = RunTracker()

    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                Map(position: $runTracker.region) {
                    UserAnnotation()

                }
                .ignoresSafeArea(edges: .bottom)

                
                Button {
                    runTracker.presentCountdown = true // Show countdown before starting the run
                } label: {
                    Text("Start Run")
                        .font(.title2)
                        .padding()
                        .buttonStyle(.borderedProminent)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        

                }
                .padding(.bottom, 50)
            }
    
            .fullScreenCover(isPresented: $runTracker.presentRunView, content: {
                RunView()
                    .environmentObject(runTracker) 
            })
            .transaction { transaction in
                transaction.disablesAnimations = true // Disable animations for the transition
            }
            .fullScreenCover(isPresented: $runTracker.presentCountdown, content: {
                CountDownView()
                    .environmentObject(runTracker) // Pass the RunTracker to the countdown view
            })
            
           
        }
        .padding(.top, -150)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)

        
    }
       
    
}
    

#Preview {
    HomeView()
        .environmentObject(RunTracker()) // Provide the RunTracker to the preview
}
