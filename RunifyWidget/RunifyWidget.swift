//
//  RunifyWidget.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let sampleRun = SharedRunData(
            distance: 5000,
            duration: 1800,
            pace: 6.0,
            locationName: "Central Park",
            date: Date(),
            isRunning: false
        )
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            runData: sampleRun,
            runs: [sampleRun]
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let runs = SharedRunData.loadRecentRuns()
        let runData = runs.first ?? SharedRunData(
            distance: 0,
            duration: 0,
            pace: 0,
            locationName: "No runs yet",
            date: Date(),
            isRunning: false
        )
        return SimpleEntry(date: Date(), configuration: configuration, runData: runData, runs: runs)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let runs = SharedRunData.loadRecentRuns()
        let runData = runs.first ?? SharedRunData(
            distance: 0,
            duration: 0,
            pace: 0,
            locationName: "No runs yet",
            date: Date(),
            isRunning: false
        )
        
        let entry = SimpleEntry(date: currentDate, configuration: configuration, runData: runData, runs: runs)
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let runData: SharedRunData
    let runs: [SharedRunData]
}

struct RunifyWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "figure.run")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Runify")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Divider()
            
            // Display runs based on widget family
            if entry.runs.isEmpty || (entry.runs.count == 1 && entry.runs[0].distance == 0) {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No runs yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Start your first run!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Show runs list
                if widgetFamily == .systemSmall {
                    // Small widget - show most recent run
                    RunRowView(run: entry.runs[0])
                } else {
                    // Medium/Large widget - show multiple runs
                    let maxRuns = widgetFamily == .systemMedium ? 3 : 5
                    let displayedRuns = Array(entry.runs.prefix(maxRuns))
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(displayedRuns.enumerated()), id: \.element.id) { index, run in
                            RunRowView(run: run)
                            if index < displayedRuns.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct RunRowView: View {
    let run: SharedRunData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Location
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(run.locationName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
            }
            
            // Stats row
            HStack(spacing: 12) {
                // Distance
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(run.formattedDistance)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Time
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Time")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(run.formattedTime)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Pace
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Pace")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(run.formattedPace)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            // Date
            Text(run.date, style: .relative)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct RunifyWidget: Widget {
    let kind: String = "RunifyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            RunifyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var defaultConfig: ConfigurationAppIntent {
        ConfigurationAppIntent()
    }
}

#Preview(as: .systemSmall) {
    RunifyWidget()
} timeline: {
    let run1 = SharedRunData(
        distance: 5000,
        duration: 1800,
        pace: 6.0,
        locationName: "Central Park",
        date: Date(),
        isRunning: false
    )
    let run2 = SharedRunData(
        distance: 3200,
        duration: 1200,
        pace: 6.25,
        locationName: "Riverside Trail",
        date: Date().addingTimeInterval(-86400),
        isRunning: false
    )
    SimpleEntry(
        date: .now,
        configuration: .defaultConfig,
        runData: run1,
        runs: [run1, run2]
    )
    SimpleEntry(
        date: .now,
        configuration: .defaultConfig,
        runData: SharedRunData(
            distance: 0,
            duration: 0,
            pace: 0,
            locationName: "No runs yet",
            date: Date(),
            isRunning: false
        ),
        runs: []
    )
}
