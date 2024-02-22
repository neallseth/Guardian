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
    static let initialTime: Int = 5 // Shared constant for initial time
    @Published var timerStatus: String = "Timer is not running"
    var timer: Timer?
    var timeRemaining: Int = TimerManager.initialTime
    var isTimerRunning: Bool { timer != nil }

    var accessibilityTimerStatus: String {
        if isTimerRunning {
            return "Time remaining: \(timeRemaining) seconds"
        } else {
            return "Timer is not running"
        }
    }

    func startTimer() {
        timer?.invalidate()
        timeRemaining = TimerManager.initialTime
        timerStatus = "Time remaining: \(timeRemaining) seconds"
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
        timeRemaining = TimerManager.initialTime
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time's Up!"
        content.body = "You have been on your computer for \(TimerManager.initialTime) seconds - consider a break"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Trigger now
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

}
