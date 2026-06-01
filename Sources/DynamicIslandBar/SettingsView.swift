import SwiftUI

/// Settings / Preferences window for the app.
struct SettingsView: View {

    @AppStorage("triggerRadius") private var triggerRadius: Double = 40
    @AppStorage("autoHideDelay") private var autoHideDelay: Double = 0.5
    @AppStorage("showSystemInfo") private var showSystemInfo = true
    @AppStorage("showMenuBarApps") private var showMenuBarApps = true
    @AppStorage("enableFileTray") private var enableFileTray = true
    @AppStorage("animationDuration") private var animationDuration: Double = 0.35
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem { Label("General", systemImage: "gearshape") }

            AppearanceTab()
                .tabItem { Label("Appearance", systemImage: "paintbrush") }

            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 450, height: 300)
    }
}

// MARK: - General

struct GeneralSettingsTab: View {
    @AppStorage("triggerRadius") private var triggerRadius: Double = 40
    @AppStorage("autoHideDelay") private var autoHideDelay: Double = 0.5
    @AppStorage("showSystemInfo") private var showSystemInfo = true
    @AppStorage("showMenuBarApps") private var showMenuBarApps = true
    @AppStorage("enableFileTray") private var enableFileTray = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Section("Trigger") {
                VStack(alignment: .leading) {
                    Slider(value: $triggerRadius, in: 10...80, step: 5) {
                        Text("Trigger radius: \(Int(triggerRadius))pt")
                    }
                    Text("How close to the notch the mouse must be to show the panel.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading) {
                    Slider(value: $autoHideDelay, in: 0.1...2.0, step: 0.1) {
                        Text("Auto-hide delay: \(autoHideDelay, specifier: "%.1f")s")
                    }
                    Text("How long to wait before hiding after mouse leaves.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Features") {
                Toggle("System Info (time, battery)", isOn: $showSystemInfo)
                Toggle("Menu Bar Apps Grid", isOn: $showMenuBarApps)
                Toggle("File Staging Tray", isOn: $enableFileTray)
                Toggle("Launch at Login", isOn: $launchAtLogin)
            }
        }
        .padding()
        .formStyle(.grouped)
    }
}

// MARK: - Appearance

struct AppearanceTab: View {
    @AppStorage("animationDuration") private var animationDuration: Double = 0.35
    @AppStorage("panelWidth") private var panelWidth: Double = 400
    @AppStorage("cornerRadius") private var cornerRadius: Double = 20

    var body: some View {
        Form {
            Section("Animation") {
                VStack(alignment: .leading) {
                    Slider(value: $animationDuration, in: 0.15...0.8, step: 0.05) {
                        Text("Duration: \(animationDuration, specifier: "%.2f")s")
                    }
                    Text("Speed of the expand/collapse animation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Panel") {
                VStack(alignment: .leading) {
                    Slider(value: $panelWidth, in: 280...500, step: 10) {
                        Text("Width: \(Int(panelWidth))pt")
                    }
                }

                VStack(alignment: .leading) {
                    Slider(value: $cornerRadius, in: 8...30, step: 2) {
                        Text("Corner radius: \(Int(cornerRadius))pt")
                    }
                }
            }
        }
        .padding()
        .formStyle(.grouped)
    }
}

// MARK: - About

struct AboutTab: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cpu")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Dynamic Island Bar")
                .font(.title2)
                .bold()

            Text("Version 1.0")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text(
                "A macOS utility that reveals hidden menu bar items " +
                "and provides a file staging area, inspired by the " +
                "iPhone Dynamic Island."
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()

            Text("Requires macOS 14+ (Sonoma)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Request Accessibility Permission") {
                StatusItemFetcher.requestAccessibilityPermission()
            }
            .buttonStyle(.bordered)
            .padding(.bottom)
        }
        .padding()
    }
}