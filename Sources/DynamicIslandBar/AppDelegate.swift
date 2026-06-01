import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private var notchMonitor: NotchMonitor!
    private var overlay: DynamicIslandOverlay!
    private var fileTrayManager: FileTrayManager!
    private var statusItemFetcher: StatusItemFetcher!

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Setup file tray manager
        fileTrayManager = FileTrayManager()

        // 2. Setup status item fetcher
        statusItemFetcher = StatusItemFetcher()

        // 3. Setup menu bar icon
        setupMenuBarItem()

        // 4. Setup Dynamic Island overlay window
        overlay = DynamicIslandOverlay(
            fileTrayManager: fileTrayManager,
            statusItemFetcher: statusItemFetcher
        )

        // 5. Setup notch mouse tracking
        notchMonitor = NotchMonitor { [weak self] isNear in
            guard let self = self else { return }
            if isNear {
                self.overlay.show()
            } else {
                self.overlay.hide()
            }
        }
    }

    // MARK: - Menu Bar

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "Dynamic Island Bar")
            button.action = #selector(toggleSettings)
            button.target = self
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(toggleSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func toggleSettings() {
        if #available(macOS 14, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}