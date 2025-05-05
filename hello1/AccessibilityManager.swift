import Foundation
import AppKit
import SwiftUI

class AccessibilityManager: ObservableObject {
    @Published var capturedText: String = ""
    @Published var isAccessibilityEnabled: Bool = false
    @Published var debugInfo: String = ""
    @Published var hasCompletedInitialCheck: Bool = false
    private var eventMonitor: Any?
    private var hasRequestedPermission = false
    
    init() {
        print("AccessibilityManager initialized")
        // Check accessibility immediately
        checkAccessibility()
    }
    
    func checkAccessibility() {
        print("Checking accessibility...")
        print("Current state - isAccessibilityEnabled: \(isAccessibilityEnabled), hasRequestedPermission: \(hasRequestedPermission)")
        
        // Only show the prompt if we haven't requested permission before
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: !hasRequestedPermission]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        print("AXIsProcessTrustedWithOptions returned: \(accessEnabled)")
        
        hasRequestedPermission = true
        
        DispatchQueue.main.async {
            print("Updating UI on main thread")
            print("Previous isAccessibilityEnabled: \(self.isAccessibilityEnabled)")
            self.isAccessibilityEnabled = accessEnabled
            print("New isAccessibilityEnabled: \(self.isAccessibilityEnabled)")
            
            self.debugInfo = """
            App Path: \(Bundle.main.bundlePath)
            Process ID: \(ProcessInfo.processInfo.processIdentifier)
            Accessibility Enabled: \(accessEnabled)
            Bundle Identifier: \(Bundle.main.bundleIdentifier ?? "Unknown")
            Has Requested Permission: \(self.hasRequestedPermission)
            Previous State: \(self.isAccessibilityEnabled)
            Current State: \(accessEnabled)
            """
            
            if accessEnabled {
                print("Accessibility enabled, setting up global shortcut")
                self.setupGlobalShortcut()
            } else {
                print("Accessibility not enabled, opening System Preferences")
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            
            // Mark that we've completed the initial check
            self.hasCompletedInitialCheck = true
        }
    }
    
    func setupGlobalShortcut() {
        // Remove existing monitor if any
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        // Register for global keyboard shortcut (Control + J)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.control) && event.keyCode == 38 { // 38 is 'J'
                self?.captureTextUnderCursor()
                
            }
        }
    }
    
    
    private func captureTextUnderCursor() {
     
        let systemWideElement = AXUIElementCreateSystemWide()
        print("systemWideElement: \(String(describing: systemWideElement))")

         var focusedElement: AnyObject?
         AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
         print("focusedElement: \(String(describing: focusedElement))")

    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
} 
