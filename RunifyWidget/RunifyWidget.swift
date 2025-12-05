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
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            runData: SharedRunData(
                distance: 5000,
                duration: 1800,
                pace: 6.0,
                locationName: "Central Park",
                date: Date(),
                isRunning: false
            )
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let runData = SharedRunData.loadRecentRun() ?? SharedRunData(
            distance: 0,
            duration: 0,
            pace: 0,
            locationName: "No runs yet",
            date: Date(),
            isRunning: false
        )
        return SimpleEntry(date: Date(), configuration: configuration, runData: runData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let runData = SharedRunData.loadRecentRun() ?? SharedRunData(
            distance: 0,
            duration: 0,
            pace: 0,
            locationName: "No runs yet",
            date: Date(),
            isRunning: false
        )
        
        let entry = SimpleEntry(date: currentDate, configuration: configuration, runData: runData)
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let runData: SharedRunData
}

struct RunifyWidgetEntryView : View {
    var entry: Provider.Entry

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
            
            // Run Data
            if entry.runData.distance > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    // Location
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.runData.locationName)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    
                    // Distance
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(entry.runData.formattedDistance)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Time and Pace
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Time")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(entry.runData.formattedTime)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pace")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(entry.runData.formattedPace)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Date
                    Text(entry.runData.date, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
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
            }
        }
        .padding()
    }
}

struct RunifyWidget: Widget {
    let kind: String = "RunifyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            RunifyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
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
    SimpleEntry(
        date: .now,
        configuration: .defaultConfig,
        runData: SharedRunData(
            distance: 5000,
            duration: 1800,
            pace: 6.0,
            locationName: "Central Park",
            date: Date(),
            isRunning: false
        )
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
        )
    )
}
