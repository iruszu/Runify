//
//  RunOptionsSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-10.
//

import SwiftUI

struct RunOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedRoute: Route?
    @State private var isGoSelected: Bool = true
    
    // Mock recommended routes - will be replaced with real data
    private let recommendedRoutes = [
        Route(name: "Central Park Loop", distance: "5.2 km", difficulty: "Easy", time: "25 min"),
        Route(name: "Riverside Trail", distance: "3.8 km", difficulty: "Easy", time: "18 min"),
        Route(name: "Hill Challenge", distance: "7.1 km", difficulty: "Hard", time: "35 min"),
        Route(name: "Waterfront Run", distance: "4.5 km", difficulty: "Medium", time: "22 min"),
        Route(name: "Forest Path", distance: "6.3 km", difficulty: "Medium", time: "30 min")
    ]
    
    struct Route {
        let name: String
        let distance: String
        let difficulty: String
        let time: String
        
        var difficultyColor: Color {
            switch difficulty {
            case "Easy": return .green
            case "Medium": return .orange
            case "Hard": return .red
            default: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle area
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    Text("Ready to run?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                    
                    // Go option
                    Button(action: {
                        isGoSelected = true
                        selectedRoute = nil
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "figure.run")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Go")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Start running immediately")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if isGoSelected && selectedRoute == nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isGoSelected && selectedRoute == nil ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Recommended routes section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Routes")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recommendedRoutes, id: \.name) { route in
                                    RouteCard(
                                        route: route,
                                        isSelected: selectedRoute?.name == route.name
                                    ) {
                                        selectedRoute = route
                                        isGoSelected = false
                                    }
                                }
                            }
                            .padding(.leading, 20)
                            
                        
                        }
                    }
                    .padding(.top, 8)
                    
                    // Start button
                    Button(action: {
                        handleStartRun()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.headline)
                            Text("Start Run")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.hidden)
    }
    
    private func handleStartRun() {
        dismiss()
        
        // Start countdown immediately
        // TODO: Pass selected route to run tracker if a route is selected
        coordinator.navigateToCountdown()
    }
}

// Route card component
struct RouteCard: View {
    let route: RunOptionsSheet.Route
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Route name
                Text(route.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Distance and time
                HStack(spacing: 12) {
                    Label(route.distance, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(route.time, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Difficulty badge
                HStack {
                    Text(route.difficulty)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(route.difficultyColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                }
            }
            .padding(12)
            .frame(width: 160, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RunOptionsSheet()
        .environmentObject(AppCoordinator())
}
