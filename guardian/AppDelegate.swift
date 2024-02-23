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
    var window: NSWindow?
    var timerManager = TimerManager() // Reference to TimerManager
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self

        requestNotificationPermission()
        registerForLockUnlockNotifications()

        // Setup the menu bar item
        setupMenuBarItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
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

    @objc func screenLocked() {
        timerManager.resetTimer()
    }

    @objc func screenUnlocked() {
        timerManager.startTimer()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }

    // MARK: - Menu Bar Setup
    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Clock")
            button.action = #selector(toggleWindow(_:))
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open App", action: #selector(toggleWindow(_:)), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }

    @objc func toggleWindow(_ sender: Any?) {
        // Implement logic to show/hide your app's main window or perform other actions
        // This is where you could show the main app window if it's not visible, or bring it to the front if it is.
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // If the window doesn't exist, create it or show an alert/error as appropriate
        }
    }
}
