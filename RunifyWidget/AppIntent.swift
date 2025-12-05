//
//  AppIntent.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Runify Widget Configuration" }
    static var description: IntentDescription { "Configure your Runify widget to display your running stats." }

    // Widget configuration - currently no parameters needed
    // Future: Could add options like showing distance in km/miles, etc.
}
