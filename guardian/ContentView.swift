//
//  ContentView.swift
//  guardian
//
//  Created by Neall Seth on 2/21/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(timerManager.timerStatus)
                .padding()
                .accessibilityLabel(timerManager.accessibilityTimerStatus)
            if timerManager.isTimerRunning {
                Button("Reset Timer") {
                    timerManager.resetTimer()
                }
            } else {
                Button("Start Timer") {
                    timerManager.startTimer()
                }
            }
        }
        .padding()
    }
}
