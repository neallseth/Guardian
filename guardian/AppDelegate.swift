//
//  AppDelegate.swift
//  guardian
//
//  Created by Neall Seth on 2/21/24.
//

import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var timerManager = TimerManager()
        var statusItem: NSStatusItem?
        var updateTimer: Timer?
        var timerStatusMenuItem: NSMenuItem?
        var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
            UNUserNotificationCenter.current().delegate = self
            
            setupMenuBarItem()
            updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeText), userInfo: nil, repeats: true)
            updateTimeText()
            requestNotificationPermission()
            registerForLockUnlockNotifications()
            timerManager.startTimer()
        }

    func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
        updateTimer?.invalidate()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                } else {
                    print("Notification permission denied.")
                    if let error = error {
                        print("Error requesting notification permissions: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func registerForLockUnlockNotifications() {
        let notificationCenter = DistributedNotificationCenter.default()
        notificationCenter.addObserver(self, selector: #selector(screenLocked), name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(screenUnlocked), name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
    }
    
    
    @objc func openSettings() {
        let contentView = SettingsView(timerManager: timerManager)

        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 120),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered, defer: false)
            settingsWindow?.center()
            settingsWindow?.title = "Settings"
            settingsWindow?.setFrameAutosaveName("Settings")
            settingsWindow?.contentView = NSHostingView(rootView: contentView)
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }


    @objc func screenLocked() {
        timerManager.resetTimer()
    }

    @objc func screenUnlocked() {
        timerManager.startTimer()
    }

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Clock")
        }
        
        let menu = NSMenu()
        
        timerStatusMenuItem = NSMenuItem(title: "Time: 0:00", action: nil, keyEquivalent: "")
        menu.addItem(timerStatusMenuItem!)
        menu.addItem(withTitle: "Reset Time", action: #selector(resetTimer), keyEquivalent: "r")

        menu.addItem(NSMenuItem.separator())
        let settingsMenuItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "")
            menu.addItem(settingsMenuItem)

        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
    }

    
    @objc func updateTimeText() {
        let elapsedTimeInMinutes = timerManager.elapsedTime/60
            
        if let button = statusItem?.button {
                button.title = "\(elapsedTimeInMinutes) min"
        }
        
        let minutes = timerManager.elapsedTime / 60
        let seconds = timerManager.elapsedTime % 60
        timerStatusMenuItem?.title = "Time: \(String(format: "%d:%02d", minutes, seconds))"
        }
    
    @objc func resetTimer() {
        timerManager.resetTimer()
        timerManager.startTimer()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }
}

