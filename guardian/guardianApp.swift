//
//  guardianApp.swift
//  guardian
//
//  Created by Neall Seth on 2/21/24.
//

import SwiftUI

@main
struct GuardianApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(timerManager: appDelegate.timerManager) 
        }
    }
}
