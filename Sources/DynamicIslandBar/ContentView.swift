import SwiftUI

/// Main content view displayed inside the Dynamic Island popup.
/// Shows system info, menu bar apps, and the file staging area.
struct ContentView: View {

    // MARK: - Dependencies

    @ObservedObject var fileTrayManager: FileTrayManager
    @ObservedObject var statusItemFetcher: StatusItemFetcher

    @State private var settings = AppSettings()
    @State private var showSettings = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle indicator
            Capsule()
                .fill(.secondary.opacity(0.5))
                .frame(width: 40, height: 4)
                .padding(.top, 8)

            // Title
            HStack {
                Image(systemName: "cpu")
                    .font(.caption)
                Text("Dynamic Island")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 4)

            Divider()
                .padding(.horizontal, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    // System info section
                    if settings.showSystemInfo {
                        SystemInfoSection()
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                    }

                    // Menu bar apps section
                    if settings.showMenuBarApps {
                        MenuBarAppsSection(
                            apps: statusItemFetcher.menuBarApps
                        )
                        .padding(.horizontal, 12)
                    }

                    // File staging section
                    if settings.enableFileTray {
                        FileTrayView(
                            fileTrayManager: fileTrayManager
                        )
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.bottom, 8)
            }

            // Footer with quick actions
            HStack(spacing: 12) {
                QuickActionButton(symbol: "scissors", label: "Snippet") {
                    // Future: text snippet management
                }
                QuickActionButton(symbol: "folder.badge.plus", label: "Stage") {
                    openFilePicker()
                }
                QuickActionButton(symbol: "trash", label: "Clear") {
                    fileTrayManager.clearAll()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .frame(width: 400, height: 300)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Actions

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.begin { result in
            if result == .OK {
                fileTrayManager.acceptFiles(panel.urls)
            }
        }
    }
}

// MARK: - System Info Section

struct SystemInfoSection: View {
    @State private var currentDate = Date()
    @State private var batteryLevel: Int = 100
    @State private var isCharging: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 16) {
            // Date & Time
            VStack(alignment: .leading, spacing: 2) {
                Text(currentDate, style: .time)
                    .font(.system(size: 14, weight: .bold))
                Text(currentDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Battery
            HStack(spacing: 4) {
                Image(systemName: batteryIcon)
                    .font(.caption)
                Text("\(batteryLevel)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .onReceive(timer) { date in
            currentDate = date
            updateBatteryInfo()
        }
        .onAppear { updateBatteryInfo() }
    }

    private var batteryIcon: String {
        if isCharging { return "battery.100.bolt" }
        switch batteryLevel {
        case 80...100: return "battery.100"
        case 60..<80:  return "battery.75"
        case 40..<60:  return "battery.50"
        case 20..<40:  return "battery.25"
        default:       return "battery.0"
        }
    }

    private func updateBatteryInfo() {
        // Use IOPowerSources for real battery info
        // For now, read via the pmset command as fallback
        // In production, use IOKit's IOPSCopyPowerSourcesInfo
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g", "batt"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        // Parsing handled by the actual battery data
        // This is placeholder - real implementation uses IOKit
    }
}

// MARK: - Menu Bar Apps Section

struct MenuBarAppsSection: View {
    let apps: [MenuBarItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Status Items", icon: "menubar.rectangle")

            LazyVGrid(
                columns: Array(
                    repeating: .init(.flexible(), spacing: 8),
                    count: 6
                ),
                spacing: 8
            ) {
                ForEach(apps.prefix(18), id: \.id) { app in
                    AppIconView(app: app)
                }
            }
        }
    }
}

struct AppIconView: View {
    let app: MenuBarItem

    var body: some View {
        VStack(spacing: 4) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.quaternary)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(String(app.appName.prefix(2)))
                            .font(.system(size: 8))
                    )
            }
            Text(app.appName)
                .font(.system(size: 8))
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: symbol)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}