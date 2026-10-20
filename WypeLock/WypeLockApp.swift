import SwiftUI

@main
struct WypeLockApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuContent(session: appDelegate.session)
        } label: {
            MenuBarIcon(session: appDelegate.session)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let session = LockSession()

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        if !AccessibilityPermission.isGranted {
            SettingsWindow.show()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        session.unlock()
    }
}

private struct MenuContent: View {
    @ObservedObject var session: LockSession

    var body: some View {
        Button("Lock Keyboard") { session.lock() }
            .disabled(session.isLocked)
        Button("Settings…") { SettingsWindow.show() }
        Divider()
        Button("Quit WypeLock") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

private struct MenuBarIcon: View {
    @ObservedObject var session: LockSession

    var body: some View {
        Image(systemName: session.isLocked ? "lock.fill" : "keyboard")
    }
}
