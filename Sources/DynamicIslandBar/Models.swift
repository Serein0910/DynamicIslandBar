import AppKit

// MARK: - Menu Bar Item

/// Represents an item shown in the macOS menu bar (right side).
struct MenuBarItem: Identifiable, Hashable {
    let id = UUID()
    /// Name of the owning application
    let appName: String
    /// Bundle identifier
    let bundleIdentifier: String
    /// App icon
    let icon: NSImage?
    /// If available, the AXUIElement reference
    let axElement: Any?

    static func == (lhs: MenuBarItem, rhs: MenuBarItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Staged File

/// A file that the user has dragged into the Dynamic Island staging area.
struct StagedFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let icon: NSImage?
    let addedAt: Date

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.icon = NSWorkspace.shared.icon(forFile: url.path)
        self.addedAt = Date()
    }
}

// MARK: - App Settings

struct AppSettings {
    /// How far the mouse must be from top-center to trigger (points)
    var triggerRadius: CGFloat = 30
    /// How long to wait before auto-hiding after mouse leaves (seconds)
    var autoHideDelay: TimeInterval = 0.5
    /// Whether to show system info
    var showSystemInfo: Bool = true
    /// Whether to show menu bar apps
    var showMenuBarApps: Bool = true
    /// Whether to enable file staging
    var enableFileTray: Bool = true
    /// Animation duration for expand/collapse
    var animationDuration: TimeInterval = 0.35
}