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
                        Text("Kellie Ho")
                            .font(.largeTitle)
                            .bold()
                            .padding(.horizontal, 20)

                        // Horizontal scroll view of run summary cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 20) {
                                ForEach(runs, id: \.id) { run in
                                    RunSummaryCard(run: run)
                                        .frame(width: 330)
                                }
                            }
                            .scrollTargetLayout()
                            .padding(.horizontal, (UIScreen.main.bounds.width - 330) / 2) // Center the first card with new width
                        }
                        .scrollTargetBehavior(.viewAligned)

                    }
                }

            }
        .scrollDisabled(true)
   
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



