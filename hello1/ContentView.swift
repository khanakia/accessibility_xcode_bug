//
//  ContentView.swift
//  hello1
//
//  Created by Aman Khanakia on 03/05/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @State private var showPermissionAlert = false
    
    var body: some View {
        VStack {
            Text("Text Capture")
                .font(.headline)
                .padding(.top)
            
            TextEditor(text: $accessibilityManager.capturedText) .frame(width: 300, height: 200) .border(Color.gray, width: 1) .padding()
            if !accessibilityManager.hasCompletedInitialCheck {
                 ProgressView("Checking permissions...")
                     .padding()
             } else if !accessibilityManager.isAccessibilityEnabled {
                 VStack(spacing: 10) {
                     Text("Accessibility permissions required")
                         .foregroundColor(.red)
                         .font(.headline)
                    
                     Text(accessibilityManager.debugInfo)
                         .font(.system(.caption, design: .monospaced))
                         .padding()
                         .background(Color.gray.opacity(0.1))
                         .cornerRadius(8)
                    
                     HStack {
                         Button("Open System Preferences") {
                             NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                         }
                        
                         Button("Show App Location") {
                             let appPath = Bundle.main.bundlePath
                             NSWorkspace.shared.selectFile(appPath, inFileViewerRootedAtPath: "")
                         }
                        
                         Button("Refresh Permissions") {
                             accessibilityManager.checkAccessibility()
                         }
                     }
                     .padding()
                 }
             } else {
                 Text("Press Control + J to capture text under cursor")
                     .font(.caption)
                     .foregroundColor(.gray)
                     .padding(.bottom)
             }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            if !accessibilityManager.isAccessibilityEnabled {
                showPermissionAlert = true
            }
        }
        // .alert("Accessibility Permission Required", isPresented: $showPermissionAlert) {
        //     Button("Open System Preferences") {
        //         NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        //     }
        //     Button("Show App Location") {
        //         let appPath = Bundle.main.bundlePath
        //         NSWorkspace.shared.selectFile(appPath, inFileViewerRootedAtPath: "")
        //     }
        //     Button("Cancel", role: .cancel) { }
        // } message: {
        //     Text("This app needs accessibility permissions to capture text from other applications. Please grant permission in System Preferences.")
        // }
    }
}

#Preview {
    ContentView()
        .environmentObject(AccessibilityManager())
}
