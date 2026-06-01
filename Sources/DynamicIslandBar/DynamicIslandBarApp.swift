import AppKit
import SwiftUI

/// App entry point. Launches as a menu-bar-only background app (LSUIElement = YES).
@main
struct DynamicIslandBarApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}