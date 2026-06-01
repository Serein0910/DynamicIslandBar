import AppKit
import SwiftUI

/// Manages a borderless, transparent window that animates from the notch area
/// to display the Dynamic Island content panel.
final class DynamicIslandOverlay: NSObject {

    // MARK: - Properties

    private var window: NSWindow?
    private weak var fileTrayManager: FileTrayManager?
    private weak var statusItemFetcher: StatusItemFetcher?

    private var isVisible = false
    private var animator: NSViewAnimation?

    /// The computed frame for the collapsed "pill" state at the notch
    private var collapsedFrame: CGRect {
        guard let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 })
                ?? NSScreen.main
        else { return .zero }

        let screenFrame = screen.frame
        let pillWidth: CGFloat = 180
        let pillHeight: CGFloat = 36
        let x = screenFrame.midX - pillWidth / 2
        let y = screenFrame.maxY - pillHeight
        return CGRect(x: x, y: y, width: pillWidth, height: pillHeight)
    }

    /// The expanded frame showing the full panel
    private var expandedFrame: CGRect {
        guard let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 })
                ?? NSScreen.main
        else { return .zero }

        let screenFrame = screen.frame
        let width: CGFloat = 420
        let height: CGFloat = 320
        let x = screenFrame.midX - width / 2
        let y = screenFrame.maxY - height - 4
        return CGRect(x: x, y: y, width: width, height: height)
    }

    // MARK: - Init

    init(fileTrayManager: FileTrayManager, statusItemFetcher: StatusItemFetcher) {
        self.fileTrayManager = fileTrayManager
        self.statusItemFetcher = statusItemFetcher
        super.init()
        setupWindow()
    }

    // MARK: - Window Setup

    private func setupWindow() {
        let panel = NSPanel(
            contentRect: collapsedFrame,
            styleMask: [.borderless, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.ignoresMouseEvents = false
        panel.acceptsMouseMovedEvents = true
        panel.isMovable = false

        // Content view with SwiftUI hosting
        let hostingView = NSHostingView(
            rootView: ContentView(
                fileTrayManager: fileTrayManager!,
                statusItemFetcher: statusItemFetcher!
            )
        )
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = true
        hostingView.layer?.cornerRadius = 18
        hostingView.layer?.cornerCurve = .continuous
        hostingView.frame = panel.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]

        panel.contentView?.addSubview(hostingView)

        self.window = panel
    }

    // MARK: - Show / Hide

    func show() {
        guard let window = window, !isVisible else { return }

        // Position at collapsed state first
        window.setFrame(collapsedFrame, display: true)
        window.alphaValue = 0
        window.orderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(
                controlPoints: 0.16, 0.8, 0.4, 1.0
            )

            window.animator().setFrame(expandedFrame, display: true)
            window.animator().alphaValue = 1
        }

        isVisible = true
    }

    func hide() {
        guard let window = window, isVisible else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(
                controlPoints: 0.4, 0.0, 0.6, 1.0
            )

            window.animator().setFrame(collapsedFrame, display: true)
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            guard let self = self else { return }
            window.orderOut(nil)
            self.isVisible = false
        }
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
}