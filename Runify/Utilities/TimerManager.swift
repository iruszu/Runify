import Foundation

class TimerManager: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    
    private var timer: Timer?
    private var pausedTimeInterval: TimeInterval = 0
    private var totalElapsedTime: TimeInterval = 0
    private var timerStartDate: Date?
    
    // MARK: - Public Methods
    
    func startTimer(interval: TimeInterval, repeats: Bool, action: @escaping () -> Void) {
        // Stop any existing timer first
        stopTimer()
        
        // Reset state
        isRunning = true
        isPaused = false
        pausedTimeInterval = 0
        totalElapsedTime = 0
        timerStartDate = Date()
        
        // Create and start new timer
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak self] _ in
            action()
        }
    }
    
    func pauseTimer() {
        guard isRunning && !isPaused, let timer = timer else { return }
        
        timer.invalidate()
        self.timer = nil
        isPaused = true
        
        // Calculate how much time has elapsed
        if let startDate = timerStartDate {
            totalElapsedTime += Date().timeIntervalSince(startDate)
        }
    }
    
    func resumeTimer(interval: TimeInterval, repeats: Bool, action: @escaping () -> Void) {
        guard isPaused else { return }
        
        isPaused = false
        timerStartDate = Date()
        
        // Resume timer with remaining time
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak self] _ in
            action()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        pausedTimeInterval = 0
        totalElapsedTime = 0
        timerStartDate = nil
    }
    
    func getElapsedTime() -> TimeInterval {
        guard isRunning else { return totalElapsedTime }
        
        if let startDate = timerStartDate {
            return totalElapsedTime + Date().timeIntervalSince(startDate)
        }
        return totalElapsedTime
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopTimer()
    }
}
