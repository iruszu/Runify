//
//  RunActions.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import AppIntents
import Foundation

struct PauseRunIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause Run"
    static var description: IntentDescription = "Pause the current running session"
    
    func perform() async throws -> some IntentResult {
        // Notify the main app to pause the run
        // Using NotificationCenter for communication
        NotificationCenter.default.post(
            name: NSNotification.Name("PauseRun"),
            object: nil
        )
        
        return .result()
    }
}

struct StopRunIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Run"
    static var description: IntentDescription = "Stop the current running session"
    
    func perform() async throws -> some IntentResult {
        // Notify the main app to stop the run
        NotificationCenter.default.post(
            name: NSNotification.Name("StopRun"),
            object: nil
        )
        
        return .result()
    }
}

