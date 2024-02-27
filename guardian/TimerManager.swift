//
//  TimerManager.swift
//  guardian
//
//  Created by Neall Seth on 2/21/24.
//

import Foundation
import Combine
import UserNotifications

class TimerManager: ObservableObject {
    @Published var timerStatus: String = "Timer is not running"
        var timer: Timer?
        var timeRemaining: Int
        var startTime: Date?
    var isTimerRunning: Bool {
            return timer != nil
        }
        @Published var preferredTimerLength: Int
    
    init() {
        self.preferredTimerLength = 30
        self.timeRemaining = 30
            let initialLength = UserDefaults.standard.integer(forKey: "preferredTimerLength")
            self.preferredTimerLength = initialLength > 0 ? initialLength : 30
            self.timeRemaining = self.preferredTimerLength
    }

    var accessibilityTimerStatus: String {
        if isTimerRunning {
            return "Time remaining: \(timeRemaining) seconds"
        } else {
            return "Timer is not running"
        }
    }

    // New property to calculate elapsed time in minutes
    var elapsedTimeInMinutes: Int {
        guard let startTime = startTime else { return 0 }
        let elapsedTime = Date().timeIntervalSince(startTime)
        return Int(elapsedTime / 60) // Convert seconds to minutes
    }
    
    var elapsedTimeFormatted: String {
        guard let startTime = startTime else { return "0:00" }
        let elapsedTime = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func startTimer() {
        timer?.invalidate()
            timeRemaining = preferredTimerLength
            timerStatus = "Time remaining: \(timeRemaining) seconds"
            startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.timerStatus = "Time remaining: \(self.timeRemaining) seconds"
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.timerStatus = "Time's up!"
                self.scheduleNotification()
            }
        }
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timerStatus = "Timer is not running"
        timeRemaining = preferredTimerLength
        startTime = nil // Reset the start time
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Take a break"
        content.body = "You have been on your computer for \(preferredTimerLength/60) minutes"

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Trigger now
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
