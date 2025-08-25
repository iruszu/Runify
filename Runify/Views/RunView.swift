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
                
                VStack {
                    Text("BPM")
                    Text("BPM")
                        .bold()
                }
                
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
            Text("Time")
                .foregroundStyle(.secondary)
            Spacer()
            
            HStack {
                Button {
                    print("stop")
                    runTracker.stopRun()
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)


        
    }
    

}

#Preview {
    RunView()
        .environmentObject(RunTracker())
}
