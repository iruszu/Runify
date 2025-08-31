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

            VStack(alignment: .leading, spacing: 20) {
                DateCard(date: Date())
                    .padding(20)
       
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {

                    // Horizontal scroll view of run summary cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(runs, id: \.id) { run in
                                RunSummaryCard(run: run)
                                
                                    .frame(width: 350, height: 600)
                                    .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 8)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.0)
                                            .scaleEffect(x: phase.isIdentity ? 0.9 : 0.3, y: phase.isIdentity ? 0.9 : 0.3)
                                            .offset(y: phase.isIdentity ? 0 : 50)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .scrollTargetBehavior(.viewAligned)
                }
                    }
                    .background(Color(red: 0.078, green: 0.078, blue: 0.078))
    }

}

#Preview {
    HomeView()
        .modelContainer(for: Run.self, inMemory: true)
}
