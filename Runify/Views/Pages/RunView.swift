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
    

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack {
                    Text("\(runTracker.distance, specifier: "%.2f") m")
                        
                        
                    Text("Distance")
                        .bold()
                }
                
                Spacer()
                
//                VStack {
//                    Text("BPM")
//                    Text("BPM")
//                        .bold()
//                }
                
                Spacer()
                
                VStack {
                    Text("\(runTracker.pace, specifier: "%.2f") min/km")
                        
                    Text("Pace")
                        .bold()
                }
                
                Spacer()
            }
            Spacer()
            Text(formatTime(seconds: runTracker.elapsedTime))
                .font(.system(size: 64, weight: .bold))
                .animation(.easeInOut(duration: 0.2), value: runTracker.elapsedTime)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            Text("Time")
                .foregroundStyle(.secondary)
            Spacer()
            
            HStack {
                Button {
                    print("stop")
                    runTracker.stopRun()
                    coordinator.stopRun() // Use coordinator for navigation
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding(36)
                        .background(.black)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .glassEffect()
                
                Spacer()
                
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
                        .foregroundStyle(.white)
                        .padding(36)
                        .background(.black)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .glassEffect()
            }
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGray6))


        
    }
    

}

#Preview {
    RunView()
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}
