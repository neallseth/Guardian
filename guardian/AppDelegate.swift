//
//  AppDelegate.swift
//  guardian
//
//  Created by Neall Seth on 2/21/24.
//

import Cocoa
import SwiftUI
import UserNotifications
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var timerManager = TimerManager()
        var statusItem: NSStatusItem?
        var timerStatusMenuItem: NSMenuItem?
        var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        
        setupMenuBarItem()
        updateTimeText()
        requestNotificationPermission()
        registerForLockUnlockNotifications()
        timerManager.startTimer()
        
        timerManager.$elapsedTime
                    .receive(on: RunLoop.main)
                    .sink { [weak self] _ in
                        self?.updateTimeText()
                    }
                    .store(in: &cancellables)
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
            let elapsedTimeInMinutes = timerManager.elapsedTime / 60
            let elapsedTimeInSeconds = timerManager.elapsedTime % 60

            if let button = statusItem?.button {
                button.title = "\(elapsedTimeInMinutes)m"
            }
            
            timerStatusMenuItem?.title = "Screen time: \(String(format: "%02d:%02d", elapsedTimeInMinutes, elapsedTimeInSeconds))"
        }
    
    @objc func resetTimer() {
        timerManager.resetTimer()
        timerManager.startTimer()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }
}

