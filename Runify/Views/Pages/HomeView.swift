//
//  HomeView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    
    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    DateCard(date: Date())
                        .padding(.horizontal, 20)
                
                    
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
                        Text("Recent Runs")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 20)
                            .offset(y: 20)
                        // Horizontal scroll view of run summary cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(runs, id: \.id) { run in
                                    RunSummaryCard(run: run)
                                        .frame(width: 300) // Card width reduced by 50px
                                }
                            }
                            .scrollTargetLayout()
                            .padding(.horizontal, (UIScreen.main.bounds.width - 300) / 2) // Center the first card with new width
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .frame(height: 450) // Fixed height for horizontal scroll
                    }
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            QuickActionButton(title: "Start Run", icon: "play.fill", color: .orange)
                            QuickActionButton(title: "View Stats", icon: "chart.bar.fill", color: .blue)
                            QuickActionButton(title: "Set Goal", icon: "target", color: .green)
                        }
                        .padding(.horizontal, 20)
                    }
                }
 
            }
        .background(Color(.systemBackground))
    }
}

// MARK: - Supporting Components


struct WeatherCard: View {
    let temperature: String
    let condition: String
    let recommendation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(temperature)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(condition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(recommendation)
                .font(.subheadline)
                .foregroundColor(.orange)
                .fontWeight(.medium)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}



