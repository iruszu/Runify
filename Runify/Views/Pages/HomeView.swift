//
//  HomeView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI
import SwiftData
import MapKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var runTracker: RunTracker
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    @State private var showRunOptions = false
    @State private var pulseAnimation = false
    
    // Computed property for time-based greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning,"
        case 12..<17:
            return "Good Afternoon,"
        default:
            return "Good Evening,"
        }
    }
    
    var body: some View {
        ZStack {
            // Background map - zoomed to show user's region with planetary context
            Map(position: .constant(.region(MKCoordinateRegion(
                center: runTracker.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247),
                span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
            )))) {
                // Empty map content - just showing the background
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .disabled(true) // Make it non-interactive
            .ignoresSafeArea()
            
            // Subtle gradient overlay for content readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main content
            ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 10) {
                    DateCard(date: Date())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    
                    if runs.isEmpty {
                        VStack(spacing: 20) {
                            Text(greeting)
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                                .opacity(0.7)
                                .offset(y: 20)
          
                            Text("Kellie Ho")
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal, 20)
  
                            
                            
                            Image(systemName: "figure.run")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                                .padding(.top, 30)
                            
                            
                            Text("Get started with your first run.")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            
                            StartRunButton {
                                showRunOptions = true
                            }
                            .padding(.top, 100)
                            .shadow(
                                color: Color.white.opacity(pulseAnimation ? 0.8 : 0.3),
                                radius: pulseAnimation ? 30 : 15,
                                x: 0,
                                y: 0
                            )
                            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            .onAppear {
                                withAnimation(
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                ) {
                                    pulseAnimation = true
                                }
                            }
                            
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 400)
                    } else {
                        Text(greeting)
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .opacity(0.7)
                            .offset(y: 20)
                            .padding(.trailing, 240)
                            .padding(.bottom, 10)
                        Text("Ready to run?")
                            .font(.largeTitle)
                            .bold()
                            .padding(.horizontal, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                     
         
                        // Horizontal scroll view of run summary cards
                        GeometryReader { geometry in
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 10) {
                                    ForEach(runs, id: \.id) { run in
                                        RunSummaryCard(run: run)
                                        
                                            // OPTION 1: Scale + Fade Effect (Subtle zoom)
                                            .scrollTransition { content, phase in
                                                content
                                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                                            }

                                    }
                                }
                                .scrollTargetLayout()
                                .padding(.horizontal, runs.count == 1 ? (geometry.size.width - 300) / 2 : (geometry.size.width - 330) / 2) // Center when one run, otherwise center first card
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollDisabled(runs.count == 1) // Disable scrolling when only one run
                        }
                        .frame(height: 450)
                        
                        StartRunButton {
                            showRunOptions = true
                        }
                        

                    }
                }
            .sheet(isPresented: $showRunOptions) {
                RunOptionsSheet()
                    .environmentObject(coordinator)
                    .presentationBackground(.clear)
            }

            }
            .scrollDisabled(true)
        }
    }
}



struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassEffect(.regular.tint(.accentColor.opacity(0.1)), in: RoundedRectangle(cornerRadius: 12))
    }
}



