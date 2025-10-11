//
//  RunView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI
import AudioToolbox

struct RunView: View {
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                    
                    Text("\(runTracker.distance, specifier: "%.2f") m")
                    Text("Distance")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .shadow(radius: 3)
                        .textCase(.uppercase)
                }
                Spacer()
                
                VStack {
                    Text("\(runTracker.pace, specifier: "%.2f") min/km")
                    Text("Pace")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .shadow(radius: 3)
                        .textCase(.uppercase)
                }
                
                Spacer()
            }
            .padding(.top, 30)
  

            HStack {
                // Stop button on the left
                Button {
                    print("stop")
                    runTracker.stopRun()
                    coordinator.stopRun() // Use coordinator for navigation
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.largeTitle)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(24)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .glassEffect()
                
                Spacer()
                
                // Pause/Resume button in the middle
                Button {
                    if runTracker.isRunning {
                        print("pause")
                        runTracker.pauseRun()
                    } else {
                        print("resume")
                        runTracker.resumeRun()
                    }
                } label: {
                    Image(systemName: runTracker.isRunning ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(36)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .glassEffect()
                
                Spacer()
                
                // Placeholder button on the right
                Button {
                    print("placeholder button tapped")
                    // Add functionality here
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(24)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .glassEffect()
            }
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground).opacity(0.9)) // Adaptive background with transparency


        
    }
    

}

#Preview {
    RunView()
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}
