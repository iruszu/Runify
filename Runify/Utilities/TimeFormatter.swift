//
//  TimeFormatter.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-19.
//

import Foundation

func formatTime(seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let remainingSeconds = Int(seconds) % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}
