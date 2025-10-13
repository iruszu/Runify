import SwiftUI
import Foundation

class AppCoordinator: ObservableObject {
    @Published var navigationStack: [Int] = []
    
    // Navigation state
    @Published var showCountdown = false
    @Published var showRun = false
    @Published var showRunSummary = false
    @Published var showRunningMap = false
    
    // Navigation methods
    func navigateToCountdown() {
        showCountdown = true
    }
    
    func countdownFinished() {
        showCountdown = false
        showRunningMap = true
    }

    
    func stopRun() {
        showRunningMap = false
        showRunSummary = true
    }
    
    func finishRunSummary() {
        showRunSummary = false
    }

    
    func resetToHome() {
        navigationStack.removeAll()
        showCountdown = false
        showRun = false
        showRunSummary = false
        showRunningMap = false
    }
}
