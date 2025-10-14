//
//  ProfileView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    
    // MARK: - State
    @State private var selectedTimePeriod: TimePeriod = .week
    
    // MARK: - Computed Properties
    
    private var filteredRuns: [Run] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimePeriod {
        case .day:
            return runs.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return runs.filter { $0.date >= startOfWeek }
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return runs.filter { $0.date >= startOfMonth }
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return runs.filter { $0.date >= startOfYear }
        }
    }
    
    private var totalDistance: Double {
        filteredRuns.reduce(0) { $0 + $1.distanceInKilometers }
    }
    
    private var totalRuns: Int {
        filteredRuns.count
    }
    
    private var averagePace: Double {
        guard !filteredRuns.isEmpty else { return 0 }
        return filteredRuns.reduce(0) { $0 + $1.pace } / Double(filteredRuns.count)
    }
    
    private var personalRecords: (fastest5K: Run?, longestRun: Run?, bestPace: Run?) {
        let validRuns = filteredRuns.filter { $0.isValid }
        return (
            fastest5K: validRuns.filter { $0.distanceInKilometers >= 4.8 && $0.distanceInKilometers <= 5.2 }.min { $0.duration < $1.duration },
            longestRun: validRuns.max { $0.distanceInKilometers < $1.distanceInKilometers },
            bestPace: validRuns.min { $0.pace < $1.pace }
        )
    }
    
    private var thisWeekRuns: [Run] {
        filteredRuns
    }
    
    private var thisWeekDistance: Double {
        totalDistance
    }
    
    private var chartData: [ChartData] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimePeriod {
        case .day:
            // Show hourly data for the day
            return (0..<24).compactMap { hour in
                guard let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) else { return nil }
                let hourRuns = filteredRuns.filter { calendar.component(.hour, from: $0.date) == hour }
                let distance = hourRuns.reduce(0) { $0 + $1.distanceInKilometers }
                
                return ChartData(
                    label: String(format: "%02d:00", hour),
                    distance: distance,
                    date: date
                )
            }
        case .week:
            // Show daily data for the week
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return (0..<7).compactMap { dayOffset in
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { return nil }
                let dayRuns = filteredRuns.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let distance = dayRuns.reduce(0) { $0 + $1.distanceInKilometers }
                
                return ChartData(
                    label: calendar.shortWeekdaySymbols[dayOffset],
                    distance: distance,
                    date: date
                )
            }
        case .month:
            // Show weekly data for the month
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let weeksInMonth = calendar.range(of: .weekOfYear, in: .month, for: now)?.count ?? 4
            
            return (0..<weeksInMonth).compactMap { weekOffset in
                guard let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfMonth) else { return nil }
                let weekRuns = filteredRuns.filter { 
                    calendar.component(.weekOfYear, from: $0.date) == calendar.component(.weekOfYear, from: date)
                }
                let distance = weekRuns.reduce(0) { $0 + $1.distanceInKilometers }
                
                return ChartData(
                    label: "W\(weekOffset + 1)",
                    distance: distance,
                    date: date
                )
            }
        case .year:
            // Show monthly data for the year
            return (0..<12).compactMap { monthOffset in
                guard let date = calendar.date(byAdding: .month, value: monthOffset, to: calendar.dateInterval(of: .year, for: now)?.start ?? now) else { return nil }
                let monthRuns = filteredRuns.filter { 
                    calendar.component(.month, from: $0.date) == calendar.component(.month, from: date)
                }
                let distance = monthRuns.reduce(0) { $0 + $1.distanceInKilometers }
                
                return ChartData(
                    label: calendar.shortMonthSymbols[monthOffset],
                    distance: distance,
                    date: date
                )
            }
        }
    }
    
    private var achievements: [Achievement] {
        var earned: [Achievement] = []
        
        if runs.count >= 1 { 
            earned.append(Achievement(title: "First Steps", icon: "star.fill", color: .yellow, description: "Completed your first run"))
        }
        if runs.count >= 10 { 
            earned.append(Achievement(title: "Consistent Runner", icon: "flame.fill", color: .orange, description: "Completed 10 runs"))
        }
        if personalRecords.longestRun?.distanceInKilometers ?? 0 >= 10 { 
            earned.append(Achievement(title: "10K Master", icon: "trophy.fill", color: .blue, description: "Completed a 10K run"))
        }
        if personalRecords.bestPace?.pace ?? 999 <= 5.0 { 
            earned.append(Achievement(title: "Speed Demon", icon: "bolt.fill", color: .purple, description: "Sub-5 min/km pace"))
        }
        if totalDistance >= 100 {
            earned.append(Achievement(title: "Century Club", icon: "crown.fill", color: .yellow, description: "100+ km total"))
        }
        
        return earned
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // Quick Stats Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(selectedTimePeriod.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        // Time Period Filter
                        Picker("Time Period", selection: $selectedTimePeriod) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.shortName).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Total Distance", 
                            value: String(format: "%.1f km", totalDistance), 
                            icon: "location"
                        )
                        StatCard(
                            title: "Runs", 
                            value: "\(totalRuns)", 
                            icon: "figure.run"
                        )
                        StatCard(
                            title: "Avg Pace", 
                            value: String(format: "%.1f min/km", averagePace), 
                            icon: "timer"
                        )
                    }
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.3), value: selectedTimePeriod)
                }
                
                // Progress Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(selectedTimePeriod.displayName) Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    Chart(chartData, id: \.label) { data in
                        BarMark(
                            x: .value("Period", data.label),
                            y: .value("Distance (km)", data.distance)
                        )
                        .foregroundStyle(.orange.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine()
                                .foregroundStyle(.gray.opacity(0.3))
                            AxisValueLabel {
                                if let distanceValue = value.as(Double.self) {
                                    Text("\(String(format: "%.1f", distanceValue)) km")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: selectedTimePeriod)
                }
                
                // Personal Records
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Records")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        if let fastest5K = personalRecords.fastest5K {
                            RecordRow(
                                title: "Fastest 5K", 
                                value: fastest5K.formattedTime, 
                                date: fastest5K.formattedDate
                            )
                        }
                        if let longestRun = personalRecords.longestRun {
                            RecordRow(
                                title: "Longest Run", 
                                value: String(format: "%.1f km", longestRun.distanceInKilometers), 
                                date: longestRun.formattedDate
                            )
                        }
                        if let bestPace = personalRecords.bestPace {
                            RecordRow(
                                title: "Best Pace", 
                                value: String(format: "%.1f min/km", bestPace.pace), 
                                date: bestPace.formattedDate
                            )
                        }
                        
                        if personalRecords.fastest5K == nil && personalRecords.longestRun == nil && personalRecords.bestPace == nil {
                            Text("Complete your first run to see personal records!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
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
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                // Split value and unit for better formatting
                let components = value.components(separatedBy: " ")
                if components.count >= 2 {
                    HStack(alignment: .bottom, spacing: 2) {
                        Text(components[0])
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(components[1])
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(value)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(.orange.opacity(0.1)), in: RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)
        .frame(height: 100) // Fixed height for equal dimensions
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
    let description: String?
    
    init(title: String, icon: String, color: Color, description: String? = nil) {
        self.title = title
        self.icon = icon
        self.color = color
        self.description = description
    }
    
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

// MARK: - Data Models

enum TimePeriod: CaseIterable {
    case day, week, month, year
    
    var shortName: String {
        switch self {
        case .day: return "D"
        case .week: return "W"
        case .month: return "M"
        case .year: return "Y"
        }
    }
    
    var displayName: String {
        switch self {
        case .day: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }
}

struct ChartData {
    let label: String
    let distance: Double
    let date: Date
}

struct Achievement {
    let title: String
    let icon: String
    let color: Color
    let description: String
}

#Preview {
    let container = try! ModelContainer(for: Run.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    return ProfileView()
        .modelContainer(container)
}

