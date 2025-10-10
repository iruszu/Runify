import SwiftUI
import Foundation

enum AppRoute {
    case home
    case countdown
    case run
    case runSummary
    case runningMap
}

class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .home
    @Published var navigationStack: [AppRoute] = []
    
    // Navigation state
    @Published var showCountdown = false
    @Published var showRun = false
    @Published var showRunSummary = false
    @Published var showRunningMap = false
    
    // Navigation methods
    func navigateToCountdown() {
        currentRoute = .countdown
        showCountdown = true
    }
    
    func countdownFinished() {
        showCountdown = false
        currentRoute = .runningMap
        showRunningMap = true
    }
    
    func startRun() {
        currentRoute = .run
        showRun = true
    }
    
    func stopRun() {
        showRunningMap = false
        currentRoute = .runSummary
        showRunSummary = true
    }
    
    func finishRunSummary() {
        showRunSummary = false
        currentRoute = .home
    }
    
    func goBack() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
            if let previousRoute = navigationStack.last {
                currentRoute = previousRoute
            } else {
                currentRoute = .home
            }
        }
    }
    
    func resetToHome() {
        currentRoute = .home
        navigationStack.removeAll()
        showCountdown = false
        showRun = false
        showRunSummary = false
        showRunningMap = false
    }
}
