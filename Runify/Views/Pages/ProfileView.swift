//
//  ProfileView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Profile Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kellie Ho")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Running Enthusiast")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Member since October 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                
                // Quick Stats Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 20) {
                        StatCard(title: "Total Distance", value: "25.2 km", icon: "location")
                        StatCard(title: "Runs", value: "7", icon: "figure.run")
                        StatCard(title: "Avg Pace", value: "5.8 min/km", icon: "timer")
                    }
                    .padding(.horizontal, 20)
                }
                
                // Weekly Progress Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<7) { day in
                            VStack {
                                Rectangle()
                                    .fill(.orange)
                                    .frame(width: 30, height: CGFloat([60, 40, 80, 20, 70, 50, 90][day]))
                                    .cornerRadius(4)
                                
                                Text(["M", "T", "W", "T", "F", "S", "S"][day])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Personal Records
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Records")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        RecordRow(title: "Fastest 5K", value: "23:45", date: "Oct 5")
                        RecordRow(title: "Longest Run", value: "15.2 km", date: "Sep 28")
                        RecordRow(title: "Best Pace", value: "4.2 min/km", date: "Oct 2")
                    }
                    .padding(.horizontal, 20)
                }
                
                // Achievements
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Achievements")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            AchievementBadge(title: "First Run", icon: "star.fill", color: .yellow)
                            AchievementBadge(title: "5K Master", icon: "trophy.fill", color: .orange)
                            AchievementBadge(title: "Consistent", icon: "flame.fill", color: .red)
                            AchievementBadge(title: "Speed Demon", icon: "bolt.fill", color: .purple)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        SettingsRow(title: "Notifications", icon: "bell.fill", color: .blue)
                        SettingsRow(title: "Units", icon: "ruler.fill", color: .green)
                        SettingsRow(title: "Privacy", icon: "lock.fill", color: .red)
                        SettingsRow(title: "About", icon: "info.circle.fill", color: .gray)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 100) // Extra padding for tab bar
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .glassEffect(.regular.tint(.orange.opacity(0.1)), in: RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)
    }
}

struct RecordRow: View {
    let title: String
    let value: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    let container = try! ModelContainer(for: Run.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    return ProfileView()
        .modelContainer(container)
}

