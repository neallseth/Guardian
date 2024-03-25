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
        @Published var elapsedTime: Int = 0  // Ensure this is published to allow Combine to observe changes
        var timer: Timer?
        var startTime: Date?

        var isTimerRunning: Bool {
            return timer != nil
        }
    
    @Published var preferredTimerLengthMinutes: Int {
            didSet {
                UserDefaults.standard.set(preferredTimerLengthMinutes, forKey: "preferredTimerLengthMinutes")
            }
        }
    init() {
            let savedPreferredLengthMinutes = UserDefaults.standard.integer(forKey: "preferredTimerLengthMinutes")
            self.preferredTimerLengthMinutes = (savedPreferredLengthMinutes > 0 ? savedPreferredLengthMinutes : 30)
        }
        
        var accessibilityTimerStatus: String {
            if isTimerRunning {
                return "Time elapsed: \(elapsedTime/60) minutes"
            } else {
                return "Timer is not running"
            }
        }
    func startTimer() {
        timer?.invalidate()
        elapsedTime = 0
        timerStatus = "Timer is running"
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
                self.elapsedTime += 1
                self.timerStatus = "Time elapsed: \(self.elapsedTime/60) minutes"
                if self.elapsedTime == self.preferredTimerLengthMinutes*60 {
                self.timerStatus = "Time's up!"
                self.scheduleNotification(seconds: self.elapsedTime)
                }
        }
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timerStatus = "Timer is not running"
        elapsedTime = 0
        startTime = nil
    }

    private func scheduleNotification(seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Take a break"
        content.body = "\(seconds/60) minutes of continuous screen time"

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Trigger now
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
