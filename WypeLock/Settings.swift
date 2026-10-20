import Combine
import SwiftUI

enum Preferences {
    static let lockDurationKey = "lockDuration"
    static let blocksTrackpadKey = "blocksTrackpad"
    static let defaultLockDuration: TimeInterval = 120
    static let lockDurationChoices: [TimeInterval] = [30, 60, 120, 180, 300, 600]

    static var lockDuration: TimeInterval {
        UserDefaults.standard.double(forKey: lockDurationKey)
    }

    static var blocksTrackpad: Bool {
        UserDefaults.standard.bool(forKey: blocksTrackpadKey)
    }

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            lockDurationKey: defaultLockDuration,
            blocksTrackpadKey: false,
        ])
    }
}

@MainActor
enum SettingsWindow {
    private static var window: NSWindow?

    static func show() {
        if window == nil {
            let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView()))
            window.title = String(localized: "WypeLock Settings")
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

struct SettingsView: View {
    @AppStorage(Preferences.lockDurationKey) private var lockDuration = Preferences.defaultLockDuration
    @AppStorage(Preferences.blocksTrackpadKey) private var blocksTrackpad = false
    @State private var isAccessibilityGranted = AccessibilityPermission.isGranted

    private let permissionRefresh = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Form {
            Section("Accessibility") {
                if isAccessibilityGranted {
                    Label {
                        Text("WypeLock is allowed to block the keyboard.")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                } else {
                    Label {
                        Text("WypeLock needs Accessibility access to intercept key presses. Enable WypeLock in System Settings > Privacy & Security > Accessibility.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    }
                    Button("Open System Settings") {
                        AccessibilityPermission.request()
                        AccessibilityPermission.openSystemSettings()
                    }
                }
            }

            Section("Locking") {
                Picker("Unlock automatically after", selection: $lockDuration) {
                    ForEach(Preferences.lockDurationChoices, id: \.self) { seconds in
                        Text(Duration.seconds(seconds).formatted(.units(allowed: [.minutes, .seconds], width: .wide)))
                            .tag(seconds)
                    }
                }
                Toggle(isOn: $blocksTrackpad) {
                    Text("Lock the trackpad too")
                    Text("Only the timer can end the lock when the trackpad is locked.")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .onReceive(permissionRefresh) { _ in
            isAccessibilityGranted = AccessibilityPermission.isGranted
        }
    }
}
