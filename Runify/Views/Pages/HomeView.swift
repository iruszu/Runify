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
    
    var body: some View {
        ZStack {
            // Background map - zoomed to show user's region with planetary context
            Map(position: .constant(.region(MKCoordinateRegion(
                center: runTracker.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247),
                span: MKCoordinateSpan(latitudeDelta: 70, longitudeDelta: 70)
            )))) {
                // Empty map content - just showing the background
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .disabled(true) // Make it non-interactive
            .ignoresSafeArea()

            
            // Main content
            ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                    DateCard(date: Date())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    
                    if runs.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No runs yet")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Complete your first run to see it here")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 400)
                    } else {
                        Text("Good Afternoon,")
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .opacity(0.7)
                            .offset(y: 20)
                            .padding(.trailing, 220)
                        Text("Kellie Ho")
                            .font(.largeTitle)
                            .bold()
                            .padding(.horizontal, 20)
                            .padding(.trailing, 200)

                        // Horizontal scroll view of run summary cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(runs, id: \.id) { run in
                                    RunSummaryCard(run: run)
                                        .frame(width: 300)
                                }
                            }
                            .scrollTargetLayout()
                            .padding(.horizontal, (UIScreen.main.bounds.width - 330) / 2) // Center the first card with new width
                        }
                        .scrollTargetBehavior(.viewAligned)
                        
                        StartRunButton {
                            showRunOptions = true
                        }
                        .padding(.top, 20)
                        

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



