//
//  CountDownView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI

struct CountDownView: View {
    @EnvironmentObject var runTracker: RunTracker
    @StateObject private var countdownTimer = TimerManager()
    @State var countdown: Int = 3
    var body: some View {
        Text("\(countdown)")
            .font(.system(size: 256, weight: .regular, design: .default))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue)
            .foregroundColor(.white)
            .onAppear {
                startCountdown()
            }
            .onDisappear {
                countdownTimer.stopTimer()
            }
    }
    
    func startCountdown() {
        countdownTimer.startTimer(interval: 1.0, repeats: true) {
            if countdown > 1 {
                countdown -= 1
            } else {
                countdownTimer.stopTimer()
                // Handle countdown completion here, e.g., navigate to another view
                runTracker.presentCountdown = false
                runTracker.startRun()
            }
        }
    }
}

#Preview {
    CountDownView()
        .environmentObject(RunTracker())
}
