//
//  hello1App.swift
//  hello1
//
//  Created by Aman Khanakia on 03/05/25.
//

import SwiftUI

@main
struct hello1App: App {
    @StateObject private var accessibilityManager = AccessibilityManager()
    @State private var hasCheckedAccessibility = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessibilityManager)
                .onAppear {
                    // Check accessibility immediately when the app starts
                    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
                    let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
                    
                    DispatchQueue.main.async {
                        accessibilityManager.isAccessibilityEnabled = accessEnabled
                        accessibilityManager.hasCompletedInitialCheck = true
                        if accessEnabled {
                            accessibilityManager.setupGlobalShortcut()
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
