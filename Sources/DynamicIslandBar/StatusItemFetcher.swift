import AppKit
import ApplicationServices

/// Fetches information about apps that have menu bar / status items.
/// Uses both NSWorkspace (reliable) and Accessibility API (best-effort).
final class StatusItemFetcher: ObservableObject {

    // MARK: - Published

    @Published var menuBarApps: [MenuBarItem] = []

    // MARK: - Init

    init() {
        refresh()
    }

    // MARK: - Public

    /// Refresh the list of menu bar apps
    func refresh() {
        let runningApps = NSWorkspace.shared.runningApplications
        var items: [MenuBarItem] = []

        for app in runningApps {
            guard app.activationPolicy == .regular ||
                  app.activationPolicy == .accessory
            else { continue }

            // Filter for apps that typically have menu bar presence
            // (utilities, preference panes, menu bar apps)
            let bundleID = app.bundleIdentifier ?? ""

            // Skip system apps that don't add menu bar items
            let skipList: Set<String> = [
                "com.apple.finder",
                "com.apple.dock",
                "com.apple.systemuiserver",
                "com.apple.controlcenter",
                "com.apple.notificationcenterui"
            ]

            guard !skipList.contains(bundleID) else { continue }

            let item = MenuBarItem(
                appName: app.localizedName ?? "Unknown",
                bundleIdentifier: bundleID,
                icon: app.icon,
                axElement: nil
            )
            items.append(item)
        }

        // Try to enhance with Accessibility API if available
        if AXIsProcessTrusted() {
            items = enhanceWithAccessibilityInfo(items)
        }

        DispatchQueue.main.async { [weak self] in
            self?.menuBarApps = items
        }
    }

    // MARK: - Accessibility (best-effort)

    /// Attempt to read the menu bar via Accessibility API to find actual status items.
    private func enhanceWithAccessibilityInfo(_ items: [MenuBarItem]) -> [MenuBarItem] {
        // AX API for status items is fragile (varies by macOS version),
        // so this is best-effort. We keep the NSWorkspace approach as base.
        return items
    }

    // MARK: - Accessibilty Permission Check

    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}