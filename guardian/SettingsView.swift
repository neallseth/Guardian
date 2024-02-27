//
//  SettingsView.swift
//  guardian
//
//  Created by Neall Seth on 2/26/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Text("Timer Length")
                    .font(.headline)
                TextField("Minutes", value: $timerManager.preferredTimerLength, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
        }
        .frame(width: 300, height: 120)
        .padding()
    }
}

