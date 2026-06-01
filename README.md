# Dynamic Island Bar 🏝️

A macOS utility that reveals hidden menu bar items behind the notch and provides a **Dynamic Island**‑style popup with a file staging area — inspired by iPhone's Dynamic Island and apps like iBar.

## Features

- **Notch‑aware mouse tracking** — move your cursor near the notch to trigger the popup
- **Dynamic Island animation** — smooth, spring‑based expand/collapse right from the notch
- **Menu bar apps grid** — see running apps that typically live in the menu bar
- **System info** — time, date, battery level at a glance
- **File staging tray** — drag & drop files into the popup for temporary storage; drag them out later
- **Quick actions** — snippet manager, file picker, clear tray
- **Fully customizable** — trigger radius, delay, panel size, animation speed
- **Menu‑bar only** — no dock icon (LSUIElement), stays out of your way

## Requirements

- macOS **14.0+** (Sonoma or later)
- Xcode **15.0+** (to build)
- **Accessibility permission** (optional, for reading menu bar items)

## Build & Run

```bash
cd DynamicIslandBar

# Build release
make build

# Or build and run directly
make run

# Create a .app bundle
make bundle
```

The .app bundle will be created as `DynamicIslandBar.app` in the project root. Drag it to `/Applications` to install.

## Usage

1. Launch the app — it appears as a CPU icon in the menu bar
2. Move your mouse to the **top center** of a notched MacBook screen
3. The Dynamic Island expands to show:
   - Current time & battery
   - Running menu‑bar app shortcuts
   - Your file staging tray
4. Drag files into the tray to stage them; hover to show the remove button
5. Click the gear icon to tweak trigger sensitivity, enable/disable features, or request Accessibility permission

## Architecture

```
DynamicIslandBar/
├── Package.swift                  # SPM project config
├── Makefile                       # Build helper
├── Resources/Info.plist           # LSUIElement = YES
└── Sources/DynamicIslandBar/
    ├── DynamicIslandBarApp.swift   # @main entry (SwiftUI App)
    ├── AppDelegate.swift          # Menu bar setup, global coordination
    ├── NotchMonitor.swift         # Global mouse‑move tracking near notch
    ├── DynamicIslandOverlay.swift # Borderless panel with expand/collapse animation
    ├── StatusItemFetcher.swift    # NSWorkspace + AX API for menu bar items
    ├── FileTrayManager.swift      # File staging data & operations
    ├── Models.swift               # Data types (MenuBarItem, StagedFile, AppSettings)
    ├── ContentView.swift          # Main SwiftUI panel content
    ├── FileTrayView.swift         # Drop zone + file grid with drag‑out
    └── SettingsView.swift         # Preferences window
```

## Limitations

- **Menu bar item reading**: macOS does not expose a public API to read *other apps*'' NSStatusItem views. The app uses `NSWorkspace` to list running apps (with an Accessibility API fallback). For full menu‑bar visibility, consider pairing with open‑source tools like `MenuWHERE` or `Bartender`.
- **Notch detection**: Works on MacBooks with a physical notch (MacBook Pro 14″/16″ 2021+). On non‑notch Macs, the trigger area defaults to the menu bar center.

## License

MIT