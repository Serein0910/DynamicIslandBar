import AppKit
import Combine

/// Monitors global mouse position and detects when the cursor
/// approaches the notch area (top-center of the screen).
final class NotchMonitor {

    // MARK: - Configuration

    /// Radius from screen top-center that triggers the Dynamic Island.
    /// Adjustable via settings.
    var triggerRadius: CGFloat = 40 {
        didSet { updateTrackingRect() }
    }

    /// Delay before auto-hide after mouse leaves
    var autoHideDelay: TimeInterval = 0.5

    // MARK: - Callbacks

    var onProximityChanged: ((Bool) -> Void)?

    // MARK: - Private

    private var isNearNotch = false
    private var monitor: Any?
    private var hasNotch = false
    private var notchScreen: NSScreen?
    private var hideWorkItem: DispatchWorkItem?

    // MARK: - Init

    init(onProximityChanged: ((Bool) -> Void)? = nil) {
        self.onProximityChanged = onProximityChanged
        detectNotchScreen()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Notch Detection

    /// Detect if the current screen has a notch by checking safe area insets.
    private func detectNotchScreen() {
        for screen in NSScreen.screens {
            if screen.safeAreaInsets.top > 0 {
                hasNotch = true
                notchScreen = screen
                return
            }
        }
        // Fallback: assume the main screen if no notch detected
        // (for testing on Macs without notch)
        hasNotch = NSScreen.screens.first?.frame.width ?? 0 > 1700
        notchScreen = NSScreen.main
    }

    // MARK: - Tracking

    private func startMonitoring() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) {
            [weak self] event in
            self?.handleMouseMove(event)
        }
    }

    private func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func handleMouseMove(_ event: NSEvent) {
        guard let screen = notchScreen else { return }

        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.frame
        let screenRect = screen.visibleFrame

        // The notch is at the top-center of the physical screen.
        // We measure from the top of the physical frame.
        let notchCenterX = screenFrame.midX
        let notchCenterY = screenFrame.maxY

        let dx = mouseLocation.x - notchCenterX
        let dy = mouseLocation.y - notchCenterY

        // Horizontal trigger region: narrower than full screen width (~400pt wide)
        let horizontalRange: CGFloat = 200
        // Vertical trigger region: only very close to the top
        let verticalRange: CGFloat = triggerRadius

        let isInNotchZone = abs(dx) <= horizontalRange && dy >= -verticalRange

        cancelHide()

        if isInNotchZone, !isNearNotch {
            isNearNotch = true
            onProximityChanged?(true)
        } else if !isInNotchZone, isNearNotch {
            // Start auto-hide countdown
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.isNearNotch = false
                self.onProximityChanged?(false)
            }
            hideWorkItem = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + autoHideDelay,
                execute: workItem
            )
        }
    }

    private func updateTrackingRect() {
        // Sensitivity adjustment is handled in handleMouseMove
    }

    private func cancelHide() {
        hideWorkItem?.cancel()
        hideWorkItem = nil
    }

    // MARK: - Manual Control

    /// Force show the Dynamic Island (programmatic trigger)
    func forceShow() {
        cancelHide()
        isNearNotch = true
        onProximityChanged?(true)
    }

    /// Force hide
    func forceHide() {
        cancelHide()
        isNearNotch = false
        onProximityChanged?(false)
    }
}