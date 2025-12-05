//
//  RunifyWidgetControl.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import AppIntents
import SwiftUI
import WidgetKit

struct RunifyWidgetControl: ControlWidget {
    static let kind: String = "com.kellieho.Runify.RunifyWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                value.isRunning ? "Stop Run" : "Start Run",
                isOn: value.isRunning,
                action: ToggleRunIntent()
            ) { isRunning in
                Label(
                    isRunning ? "Stop" : "Start",
                    systemImage: isRunning ? "stop.circle.fill" : "play.circle.fill"
                )
            }
        }
        .displayName("Run Control")
        .description("Start or stop your run from Control Center.")
    }
}

extension RunifyWidgetControl {
    struct Value {
        var isRunning: Bool
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: RunConfiguration) -> Value {
            RunifyWidgetControl.Value(isRunning: false)
        }

        func currentValue(configuration: RunConfiguration) async throws -> Value {
            // Check if run is active from shared data
            if let activeRun = SharedRunData.loadActiveRun() {
                return RunifyWidgetControl.Value(isRunning: activeRun.isRunning)
            }
            return RunifyWidgetControl.Value(isRunning: false)
        }
    }
}

struct RunConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Run Control Configuration"
}

struct ToggleRunIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start or stop a run"

    @Parameter(title: "Run is active")
    var value: Bool

    init() {}

    func perform() async throws -> some IntentResult {
        // Update shared data to indicate run state change
        // The main app should listen for this change and start/stop the run accordingly
        if value {
            // Starting run - create active run data
            let activeRun = SharedRunData(
                distance: 0,
                duration: 0,
                pace: 0,
                locationName: "Starting...",
                date: Date(),
                isRunning: true,
                elapsedTime: 0,
                startTime: Date()
            )
            SharedRunData.saveActiveRun(activeRun)
        } else {
            // Stopping run - clear active run
            SharedRunData.clearActiveRun()
        }
        
        // Notify the main app via notification or URL scheme
        // This is a simplified approach - in production, you might want to use
        // a more robust communication method
        return .result()
    }
}
